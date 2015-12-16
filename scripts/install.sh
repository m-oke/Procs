#! /bin/sh
set -eu
LOGFILE=/tmp/procs_install.log

command_exists() {
    command -v "$@" > /dev/null 2>&1
}

install_essentials() {
    echo "Install packages"
    $sh_c "add-apt-repository ppa:chris-lea/redis-server"
    $sh_c "apt-get update"
    $sh_c "apt-get install git build-essential libssl-dev nodejs libreadline-dev"
}

install_db(){
    # if command_exists mysql; then
    #     mysql_version="$(mysql --version | sed "s/,.*$//" | sed "s/^.*Distrib //")"
    # fi
    echo "Install database packages"
    $sh_c "apt-get install mysql-server-5.6 redis-server libmysqld-dev"
}

install_ruby() {
    echo "Install ruby"
    git clone https://github.com/sstephenson/rbenv.git ~/.rbenv
    echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
    echo 'eval "$(rbenv init -)"' >> ~/.bashrc
    source ~/.bashrc
    git clone https://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build
    rbenv install 2.2.3
    rbenv rehash
    rbenv global 2.2.3
}

install_rails() {
    echo "Install Ruby on Rails"
    gem install rails --version='4.2.1' --no-ri --no-rdoc
}

install_docker(){
    echo "Install Docker"
    curl -sSL https://get.docker.com/ | sh
    $sh_c "usermod -aG docker $USER"
}

install_procs(){
    cp $dir/config/database.yml.sample $dir/config/database.yml

#    git checkout master

    echo "==========Setup Procs settings =========="
    echo -n "Who MySQL user for Procs is ? (default: root) :"
    read mysql_user
    mysql_user=${mysql_user:-root}
    echo

    echo -n "Password for $mysql_user is ? : "
    stty -echo
    read mysql_pass
    stty echo

    echo "Setting user and password..."
    echo "PROCS_DATABASE_USER='${mysql_user}'" >> $dir/.env
    echo "PROCS_DATABASE_PASSWORD='${mysql_pass}'" >> $dir/.env
    echo "SECRET_KEY_BASE='$(rake secret)'" >> $dir/.env
    echo "Set user and password to ${dir}/.env"
    echo "If you have any misstakes, please edit ${dir}/.env file."
    echo "Warning: Don't edit/delete SECRET_KEY_BASE Strings."


    # mysqlを設定する
    echo -n "Is ${mysql_user} existed in MySQL? [y/n] : "
    create=""
    while read conf; do
        case $conf in
            'y' ) create="false"
                break ;;
            'n' ) create="true"
                break ;;
            * ) echo "Please type y or n."
                echo -n "${mysql_user} is existed in MySQL? [y/n] : " ;;
        esac
    done

    echo -n "Does root user in MySQL has password? [y/n] : "
    root_p=""
    while read conf; do
        case $conf in
            'y' ) root_p="true"
                break ;;
            'n' ) root_p="false"
                break ;;
            * ) echo "Please type y or n."
                echo -n "Does root user in MySQL has password? [y/n] : " ;;
        esac
    done

    echo "Setting MySQL user for Procs..."
    if [ "$create" = "false" ] && [ "$root_p" = "true" ]; then
        mysql -u root -p -e "GRANT ALL ON Procs_production.* TO '${mysql_user}'@'localhost' IDENTIFIED BY '${mysql_pass}';"
    elif [ "$create" = "false" ] && [ "$root_p" = "false" ]; then
        mysql -u root -e "GRANT ALL ON Procs_production.* TO '${mysql_user}'@'localhost' IDENTIFIED BY '${mysql_pass}';"
    elif [ "$create" = "true" ] && [ "$root_p" = "true" ]; then
        mysql -u root -p -e "GRANT ALL ON Procs_production.* TO '${mysql_user}'@'localhost';"
    elif [ "$create" = "true" ] && [ "$root_p" = "false" ]; then
        mysql -u root -e "GRANT ALL ON Procs_production.* TO '${mysql_user}'@'localhost';"
    fi
    echo "Set MySQL user for Procs."
    echo "If you want edit, please use mysql console."

    echo "Creating DB..."
    bundle exec rake db:create:all 1> /dev/null
    echo "Created!"
    bundle exec rake assets:precompile 1> /dev/null

    echo "Procs has plagiarism detection using Web."
    echo "If you want use this, you have to get Bing Search API Key."
    echo -n "If you have Key, type here (optional) : "
    read apikey
    echo "BING_API_KEY='${apikey}'" >> $dir/.env
    echo "If you want to set apikey later, please edit ${dir}/.env ."
}

setup_nginx(){
    echo "Setting up nginx."
    $sh_c "apt-get install nginx"

    cat $dir/scripts/nginx/unicorn.conf.sample | sed "s#root#root ${dir}/public;#" > $dir/scripts/nginx/unicorn.conf
    $sh_c "cp $dir/scripts/nginx/unicorn.conf /etc/nginx/conf.d/unicorn.conf"
    $sh_c "chown root:root /etc/nginx/conf.d/unicorn.conf"
    $sh_c "service nginx restart"
}

create_root(){
    echo "Setting root user in Procs."
    echo -n "Type email of root user in Procs : "
    while read email; do
        case $email in
            '' ) echo "Not allow blank."
                echo -n "Type email of root user in Procs: "
                ;;
            * )
                break ;;
        esac
    done

    echo -n "Type nickname of root user in Procs  : "
    while read nickname; do
        case $nickname in
            '' ) echo "Not allow blank."
                echo -n "Type nickname of root user in Procs : "
                ;;
            * )
                break ;;
        esac
    done

    echo -n "Type name of root user in Procs (optional) : "
    read name

    while :
    do
        stty -echo
        echo -n "Type password of root user in Procs(8-255 characters) : "
        read password

        echo -n "Retype password of root user in Procs(8-255 characters) :"
        read confirmation

        if [ ${#password} -lt 8 -o ${#confirmation} -lt 8 ]; then
            echo "Password is too short."
            continue
        fi
        if [ ${#password} -gt 255 -o ${#confirmation} -gt 255 ]; then
            echo "Password is too long."
            continue
        fi

        if [ $password = $confirmation ]; then
            break
        else
            echo "Passwords don't match. Please retry."
        fi
    done
    stty echo

    echo "User.create(:name => '${name}', :nickname => '${nickname}', :email => '${email}', :password => '${password}', :roles => [:root, :admin, :teacher, :student])" | bundle exec rails console 2> /dev/null

}

start_unicorn(){
    bundle exec rake unicorn:start
}

do_install(){
    case "$(uname -m)" in
        *64)
            ;;
        *)
            echo "Error: you are not using a 64bit platform."
            echo "Procs uses Docker and Docker currently only supports 64bit platforms."
            exit 1
            ;;
    esac

    user="$(id -un 2>/dev/null || true)"

    sh_c='sh -c'
    if [ "$user" != 'root' ]; then
        if command_exists sudo; then
            sh_c='sudo -E sh -c'
        elif command_exists su; then
            sh_c='sh -c'
        else
            echo "Error: this installer needs the ability to run commands as root."
            echo 'We are unable to find either "sudo" or "su" available to make this happen.'
            exit 1
        fi
    fi


    # ディレクトリの設定
    dir=$(cd $(dirname $0); pwd)
    dir=$(cd ../; pwd)

    install_essentials
    install_db
    install_ruby
    install_rails
    install_procs
    setup_nginx
    create_root
    start_unicorn
    exit 0
}

do_install 2>&1 | tee "$LOGFILE"
echo "Logfile is here > ${LOGFILE}"
