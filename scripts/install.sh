#! /bin/bash
set -eu
LOGFILE=/tmp/procs_install.log

MYSQL_VERSION="5.6.28"
RUBY_VERSION="2.2.3"
RAILS_VERSION="4.2.1"
DOCKER_VERSION="1.10.1"
PYTHON_VERSION="3.4.3"
REDIS_VERSION="3.0.7"

command_exists() {
    command -v "$@" > /dev/null 2>&1
}

compareVersions ()
{
    typeset    IFS='.'
    typeset -a v1=( $1 )
    typeset -a v2=( $2 )
    typeset    n diff

    for (( n=0; n<4; n+=1 )); do
        diff=$((v1[n]-v2[n]))
        if [ $diff -ne 0 ] ; then
            [ $diff -lt 0 ] && echo '-1' || echo '1'
            return
        fi
    done
    echo  '0'
}

install_essentials() {
    echo "Install packages"
    $sh_c "add-apt-repository ppa:chris-lea/redis-server"
    $sh_c "apt-get update"
    $sh_c "apt-get install -y -q git build-essential libssl-dev nodejs libreadline-dev"
}

install_db(){
    if command_exists mysql; then
        mysql_version="$(mysql --version | sed "s/,.*$//" | sed "s/^.*Distrib //")"
        diff=`compareVersions $MYSQL_VERSION $mysql_version`
        if [ $diff -eq 1 ]; then
            echo ""
            echo "We recommended MySQL verion is $MYSQL_VERSION or higher. Installed MySQL version is older than recomended version."
            echo "If you want to upgrade MySQL, type [Yes]."
            echo "Or if you want to keep MySQL version, type [skip] or [abort]."
            echo "But if you skip MySQL upgrade, we don't support it."
            echo -n "Upgrade? [Yes/skip/abort] : "
            conf=""
            while read conf; do
                case $conf in
                    'Yes' )
                        $sh_c "apt-get -y -q upgrade mysql-server-5.6 libmysqld-dev"
                        break ;;
                    'skip' )
                        break ;;
                    'abort' )
                        echo "Abort install."
                        exit 1
                        ;;
                    * ) echo "Please type Yes or skip or abort."
                        echo -n "Upgrade? [Yes/skip/abort] : " ;;
                esac
            done
        fi
    else
        echo "Install database packages"
        $sh_c "apt-get -y -q install mysql-server-5.6 libmysqld-dev"
    fi

    if command_exists redis-server; then
        redis_version="$(redis-server --version | sed "s/sha.*$//" | sed "s/^.*=//")"
        diff=`compareVersions $REDIS_VERSION $redis_version`
        if [ $diff -eq 1 ]; then
            echo ""
            echo "We recommend Redis verion is $REDIS_VERSION or higher. Installed Redis version is older than recomended version."
            echo "If you want to upgrade Redis, type [Yes]."
            echo "Or if you want to keep Redis version, type [skip] or [abort]."
            echo "But if you skip Redis upgrade, we don't support it."
            echo -n "Upgrade? [Yes/skip/abort] : "
            conf=""
            while read conf; do
                case $conf in
                    'Yes' )
                        $sh_c "apt-get -y -q upgrade redis-server"
                        break ;;
                    'skip' )
                        break ;;
                    'abort' )
                        echo "Abort install."
                        exit 1
                        ;;
                    * ) echo "Please type Yes or skip or abort."
                        echo -n "Upgrade? [Yes/skip/abort] : " ;;
                esac
            done
        fi
    else
        $sh_c "apt-get install -q -y redis-server"
    fi
}

install_ruby() {
    echo ""
    echo "Install ruby"
    if command_exists rbenv; then
        rbenv_dir=$(which rbenv | sed "s#bin/rbenv\$##")
        cd $rbenv_dir
        git pull
        cd $dir
    else
        if [ ! -e ~/.rbenv ]; then
            git clone https://github.com/sstephenson/rbenv.git ~/.rbenv
            echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
            echo 'eval "$(rbenv init -)"' >> ~/.bashrc
            source ~/.bashrc
        fi
    fi

    if [ ! -e ~/.rbenv/plugins/ruby-build ]; then
        git clone https://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build
    else
        cd $rbenv_dir
        cd plugins/ruby-build
        git pull
        cd $dir
    fi

    if [ ! "`rbenv versions | grep "$RUBY_VERSION"`" ]; then
        rbenv install 2.2.3
        rbenv rehash
    fi
    rbenv local 2.2.3
}

install_rails() {
    echo ""
    echo "Install Ruby on Rails"
    gem install bundler --no-ri --no-rdoc
    bundle install --path $dir/vendor/bundle
}

install_docker(){
    echo ""
    echo "Install Docker"
    curl -sSL https://get.docker.com/ | sh
    $sh_c "usermod -aG docker $USER"


    if [ ! -e $dir/docker ]; then
        mkdir $dir/docker
    fi

    if [ ! -e $dir/docker/.git ]; then
        git clone https://github.com/m-oke/procs_sandbox.git $dir/docker/
    fi

    # swap memory setup
    $sh_c cp /etc/default/grub /etc/default/grub.old
    $sh_c cat /etc/default/grub  | sed 's#GRUB_CMDLINE_LINUX=".*"#GRUB_CMDLINE_LINUX="cgroups_enable=memory swapaccount=1"#' > /etc/default/grub
    $sh_c update-grub

    $sh_c docker build -t procs/python_sandbox $dir/docker/python_sandbox
    $sh_c docker build -t procs/cpp_sandbox $dir/docker/cpp_sandbox
}

install_sim(){
    $sh_c "apt-get install -q -y similarity-tester"
}

install_clonedigger(){
    $sh_c "apt-get install -q -y python-setuptools"
    $sh_c "easy_install clonedigger"
}

install_procs(){
    cp $dir/config/database.yml.sample $dir/config/database.yml
    bundle install
    cd $dir/vendor/bundle/ruby/2.2.0/gems/unicorn*/
    ./GIT-VERSION-GEN # activate unicorn
    cd $dir

    bundle exec rake db:drop RAILS_ENV=production
    echo "==========Setup Procs settings =========="
    echo -n "Who MySQL user for Procs is ? (default: root) : "
    read mysql_user
    mysql_user=${mysql_user:-root}
    echo

    echo -n "Password for $mysql_user is ? : "
    stty -echo
    read mysql_pass
    stty echo

    echo ""
    echo "Setting user and password..."
    echo "PROCS_DATABASE_USER='${mysql_user}'" > $dir/.env
    echo "PROCS_DATABASE_PASSWORD='${mysql_pass}'" >> $dir/.env
    echo "SECRET_KEY_BASE='$(bundle exec rake secret)'" >> $dir/.env
    echo "Set user and password to ${dir}/.env"
    echo "If you have any misstakes, please edit ${dir}/.env file."
    echo "Warning: Don't edit/delete SECRET_KEY_BASE Strings."

    echo ""
    echo "Create Database for Procs."
    bundle exec rake db:create RAILS_ENV=production
    echo "If you want edit, please use mysql console."

    bundle exec rake db:migrate RAILS_ENV=production
    echo "Created!"

    bundle exec rake assets:precompile 1> /dev/null

    echo ""
    echo "Procs has plagiarism detection using Web."
    echo "If you want use this, you have to get Bing Search API Key."
    echo "    Detail: https://datamarket.azure.com/dataset/bing/search"
    echo -n "If you have Key, type here (optional) : "
    read apikey
    echo "BING_APIKEY='${apikey}'" >> $dir/.env
    echo "If you want to set apikey later, please edit ${dir}/.env ."
}

setup_nginx(){
    echo ""
    echo "Setting up nginx."
    if command_exists nginx; then
        echo "Nginx is already installed."
        echo "In this installation, set nginx config of Procs to default_server."
        echo "If you have nginx config for any applcations, you should configure it manually."
        echo -n "Skip nginx configure? [Yes/No] : "
        conf=""
        while read conf; do
            case $conf in
                'Yes' )
                    echo "Config file of Procs is ($dir/scripts/nginx/procs.conf)"
                    echo "Please configure it mannually."
                    break ;;
                'No' )
                    cat $dir/scripts/nginx/procs.conf.sample | sed "s#root#root ${dir}/public;#" > $dir/scripts/nginx/procs.conf
                    $sh_c "cp $dir/scripts/nginx/procs.conf /etc/nginx/conf.d/procs.conf"
                    $sh_c "chown root:root /etc/nginx/conf.d/procs.conf"

                    if [ -e /etc/nginx/sites-enabled/default ]; then
                        $sh_c "rm /etc/nginx/sites-enabled/default"
                    fi
                    echo "For Procs server, delete enable file of default config (/etc/nginx/sites-enabled/default)."
                    echo "If you configure nginx config of Procs, edit /etc/nginx/conf.d/procs.conf."
                    break ;;
                * ) echo "Please type Yes or No."
                    echo -n "Skip nginx configure? [Yes/No] : " ;;
            esac
        done
    else
        $sh_c "apt-get install -y -q nginx"

        cat $dir/scripts/nginx/procs.conf.sample | sed "s#root#root ${dir}/public;#" > $dir/scripts/nginx/procs.conf
        $sh_c "cp $dir/scripts/nginx/procs.conf /etc/nginx/conf.d/procs.conf"
        $sh_c "chown root:root /etc/nginx/conf.d/procs.conf"

        if [ -e /etc/nginx/sites-enabled/default ]; then
            $sh_c "rm /etc/nginx/sites-enabled/default"
        fi
        echo "For Procs server, delete enable file of default config (/etc/nginx/sites-enabled/default)."
        echo "If you configure nginx config of Procs, edit /etc/nginx/conf.d/procs.conf."
    fi

    $sh_c "service nginx restart"
}

create_root(){
    echo ""
    echo "Setting root user in Procs."
    echo -n "Type email of root user in Procs : "
    while read email; do
        case $email in
            '' ) echo "Not allow blank."
                echo -n "Type email of root user in Procs : "
                ;;
            * )
                break ;;
        esac
    done

    echo -n "Type nickname of root user in Procs : "
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
        echo ""

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

    echo ""
    echo ""
    echo "User.create(:name => '${name}', :nickname => '${nickname}', :email => '${email}', :email_confirmation => '${email}', :password => '${password}', :password_confirmation => '${password}', :roles => [:root, :admin, :teacher, :student])" | bundle exec rails console -e production 2> /dev/null
    echo "Lesson.create(:name => 'パブリック問題', :description => 'このクラスはすべての問題を含むクラスです。', :lesson_code => '0000000000')" | bundle exec rails console -e production 2> /dev/null
    echo "UserLesson.create(:user_id => 1, :lesson_id => 1, :is_teacher => true)"  | bundle exec rails console -e production 2> /dev/null

}

start_unicorn(){
    bundle exec rake unicorn:stop
    bundle exec rake unicorn:start
}

start_sidekiq(){
    echo ""
    echo "Starting redis server"
    cd $dir
    bundle exec sidekiq -C $dir/config/sidekiq.yml -e production -d
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

    echo -n "This is installer of Procs. This will install softwares for system. If any softwares conflict others, type Ctrl-C for abort."
    conf=""

    # ディレクトリの設定
    # XXX/Procs/scripts/ を想定
    dir=$(cd $(dirname $0); pwd)
    dir=$(cd ../; pwd)

    install_essentials
    install_db
    install_ruby
    install_rails
    install_procs
    install_sim
    install_clonedigger
    create_root
    install_docker
    setup_nginx
    echo ""
    echo ""
    echo "Install completed!"
    echo "Please relogin, or restart server for using docker."
    echo "Then please run $dir/script/start.sh to start server."
    exit 0
}

do_install 2>&1 | tee "$LOGFILE"
echo "Logfile is here >> ${LOGFILE}"
echo "If install is aborted or failed, please drop database Procs_database, and drop mysql user."
