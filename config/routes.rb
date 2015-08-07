Rails.application.routes.draw do
  root :to => 'lessons#index'

  resources :lessons do
    resources :questions, only: [:index, :show, :new, :create], param: :question_id  do
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
      get ':lesson_id/students' => 'lessons#students', as: 'students'
      post ':lesson_id/students/:student_num' => 'lessons#student', as: 'student'
    end
  end

  scope :ajax do
    post 'answers/select_version' => 'answers#select_version'
    post 'answers/diff_select' => 'answers#diff_select'
  end

  resources :questions, only: [:index, :show], param: :question_id do
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


  devise_scope :user do
    get 'users/teacher/new', :to => 'users/registrations#new_teacher'
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
