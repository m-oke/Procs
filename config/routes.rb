# -*- coding: utf-8 -*-
Rails.application.routes.draw do
  root :to => 'lessons#index'

  resources :lessons do
    resources :questions, only: [:index, :show, :new, :create, :edit, :update, :destroy], param: :question_id, :constraints => OnlyAjaxRequest do
      member do
        get '/answers' => 'answers#index', :constraints => OnlyAjaxRequest
      end
    end
    resources :students, only: [] do
      scope '/questions/:question_id' do
        resources :answers, only: [:index]
      end
    end
    collection do
      get '/join' => 'user_lessons#new'
      post '/join' => 'user_lessons#create'
      get ':lesson_id/students' => 'lessons#students', as: 'students', :constraints => OnlyAjaxRequest
      get ':lesson_id/students/:student_id' => 'lessons#student', as: 'student', :constraints => OnlyAjaxRequest
    end
  end

  scope :ajax do
    get 'answers/select_version' => 'answers#select_version'
    get 'lessons/tab_back_home' => 'lessons#tab_back_home'
    post 'answers/diff_select' => 'answers#diff_select'
    post 'lessons/internet_check' =>'lessons#internet_check'
    post 'questions/get_exist_question' => 'questions#get_exist_question'
  end

  get '/public_questions' => 'questions#public_questions', :as => 'questions'
  resources :questions, only: [:show], param: :question_id do
    member do
      get '/answers' => 'answers#index'
    end
  end
  resources :answers, only: [:create]

  devise_for :users, :controllers => {
    :sessions => 'users/sessions',
    :registrations => 'users/registrations',
    :passwords => 'users/passwords'
  }


  # teacher作成デバッグ用
  # devise_scope :user do
  #   get 'users/teacher/new', :to => 'users/registrations#new_teacher'
  # end

  scope :help, :as => :help do
    get '/' => 'help#index'
    get '/index' => 'help#index'
    get '/user_create' => 'help#user_create'

    get '/student_attend_lesson' => 'help#student_attend_lesson'
    get '/student_view_question' => 'help#student_view_question'
    get '/student_answer' => 'help#student_answer'
    get '/student_result' => 'help#student_result'

    get 'teacher_lesson_create' => 'help#teacher_lesson_create'
    get 'teacher_question_create' => 'help#teacher_question_create'
    get 'teacher_view_answer' => 'help#teacher_view_answer'
    get 'teacher_view_result' => 'help#teacher_view_result'
    get 'teacher_web_plagirarism' => 'help#teacher_web_plagirarism'
    get 'teacher_local_plagiarism' => 'help#teacher_local_plagiarism'

    get 'admin_admin_page' => 'help#admin_admin_page'
    get 'admin_user_roles' => 'help#admin_user_roles'
  end

  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'

  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

end
