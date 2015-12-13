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
  end

end
