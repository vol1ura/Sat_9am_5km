require 'sidekiq/web'

Rails.application.routes.draw do
  default_url_options host: ENV.fetch('APP_HOST')

  root 'pages#index'

  resources :pages, only: %i[index show], param: :page do
    collection do
      get :app
      post :submit_feedback
    end
  end
  resources :events, param: :code_name, only: %i[index show] do
    get :search, on: :collection
    get :volunteering, on: :member
    get :live, on: :member
    resource :going_to, only: %i[create destroy]
  end
  resources :activities, only: %i[index show] do
    get :dashboard, on: :collection
  end
  scope path: 'athletes' do
    get ':code/best_result', to: 'athletes#best_result', defaults: { format: :json }
    resources :duels, only: %i[index show] do
      get :protocol, on: :collection
    end
  end
  resources :athletes, only: %i[index show] do
    resources :statistics, module: :athletes, only: [] do
      collection do
        get :friends
        get :followers
        get :total_events
        get :total_trophies
        get :total_results
        get :personal_best_absolute
        get :best_position_absolute
        get :volunteering_chart
      end
    end
  end
  resources :volunteers, only: %i[new edit create update destroy]
  resources :badges, only: %i[index show]
  resources :clubs, only: %i[index show] do
    get :search, on: :collection
    get :last_week, on: :member
  end
  resources :ratings, only: :index do
    collection do
      get :results
      get :table
      get :results_table
    end
  end
  resources :friendships, only: %i[create destroy]
  resources :auth_links, only: :show, module: :users, param: :token
  resources :articles, only: %i[index show], param: :page

  resource :user, only: %i[show edit update]
  resource :cookie_consent, only: :create
  resolve('User') { [:user] }

  ActiveAdmin.routes(self)

  devise_for(
    :users,
    {
      path: :user,
      controllers: {
        sessions: 'users/sessions',
        passwords: 'users/passwords',
        unlocks: 'users/unlocks',
        registrations: 'users/registrations',
        confirmations: 'users/confirmations',
        omniauth_callbacks: 'users/omniauth_callbacks',
      },
      path_names: {
        sign_in: 'login',
        sign_out: 'logout'
      },
      sign_out_via: %i[delete get]
    },
  )

  namespace :api, defaults: { format: :json } do
    namespace :internal do
      resource :user, only: :create do
        post :auth_link, on: :member
      end
      resource :athlete, only: :update
    end
    namespace :parkzhrun do
      resources :athletes, only: :update
      resources :activities, only: :create
    end
    namespace :mobile do
      get 'athletes/:code/info', to: 'athletes#info'
      post 'activities/stopwatch', to: 'activities#stopwatch'
      post 'activities/live', to: 'activities#live'
      post 'activities/scanner', to: 'activities#scanner'
    end
  end

  get 'up', to: 'rails/health#show'

  authenticate :user, ->(user) { user.super_admin? } do
    mount Sidekiq::Web => 'sidekiq' if Rails.env.production?
    mount RailsPerformance::Engine => 'app_performance'
    mount PgHero::Engine => 'pg_stats'
    mount ActiveStorageDashboard::Engine => 'storage'
  end
end
