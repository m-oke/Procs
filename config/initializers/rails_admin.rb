# -*- coding: utf-8 -*-
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

  config.main_app_name = ["Procs", "Admin page"]
  config.included_models = ["User", "Lesson", "Question", "Answer", "Sample", "TestDatum", "InternetCheckResult", "LessonQuestion", "UserLesson", "QuestionKeyword"]

  # TODO: 各モデルの必要事項を追加
  config.actions do
    dashboard                     # mandatory
    index                         # mandatory
    new
    export
    show
    edit
    delete

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
      field :email_confirmation do
        required true
      end
      field :password do
        required true
      end
      field :password_confirmation do
        required true
      end
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
      end
      field :password_confirmation
      field :lessons
      field :answers
      field :questions
    end
  end
end
