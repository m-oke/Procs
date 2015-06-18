RailsAdmin.config do |config|

  ### Popular gems integration

  ## == Devise ==
  config.authenticate_with do
    warden.authenticate! scope: :user
  end
  config.current_user_method(&:current_user)

  ## == Cancan ==
  config.authorize_with :cancan

  ## == PaperTrail ==
  # config.audit_with :paper_trail, 'User', 'PaperTrail::Version' # PaperTrail >= 3.0.0

  ### More at https://github.com/sferik/rails_admin/wiki/Base-configuration

  config.actions do
    dashboard                     # mandatory
    index                         # mandatory
    new
    export
    bulk_delete
    show
    edit
    delete
    show_in_app

    ## With an audit adapter, you can add:
    # history_index
    # history_show
  end

  config.model User do
    create do
      field :student_number
      field :name do
        required true
      end
      field :nickname do
        required true
      end
      field :roles do
        required true
        partial 'roles_form'
      end
      field :email do
        required true
      end
      field :password
      field :password_confirmation do
        required true
      end
      field :reset_password_sent_at
      field :remember_created_at
      field :sign_in_count
      field :current_sign_in_at
      field :last_sign_in_at
      field :current_sign_in_ip
      field :last_sign_in_ip
      field :user_lessons
      field :lessons
      field :answers
      field :questions
    end

    update do
      field :student_number
      field :name
      field :nickname
      field :roles do
        partial 'roles_form'
      end
      field :email
      field :password do
        required false
      end
      field :password_confirmation
      field :reset_password_sent_at
      field :remember_created_at
      field :sign_in_count
      field :current_sign_in_at
      field :last_sign_in_at
      field :current_sign_in_ip
      field :last_sign_in_ip
      field :user_lessons
      field :lessons
      field :answers
      field :questions
    end
  end

end
