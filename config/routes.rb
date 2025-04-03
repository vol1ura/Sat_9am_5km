require 'sidekiq/web'

Rails.application.routes.draw do
  default_url_options host: ENV.fetch('APP_HOST')

  root 'events#index'
  get 'pages/:page', to: 'pages#show', as: :page
  get 'up', to: 'rails/health#show'

  resources :events, param: :code_name, only: %i[index show] do
    get :search, on: :collection
    get :map, on: :collection
    get :volunteering, on: :member
    resource :going_to, only: %i[create destroy]
  end
  resources :activities, only: %i[index show]
  resources :athletes, only: %i[index show]
  resources :volunteers, only: %i[new edit create update]
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

  resource :user, only: %i[show edit update]
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
      resource :user, only: %i[create update] do
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
    end
  end

  authenticate :user, ->(user) { user.admin? } do
    mount Sidekiq::Web => 'sidekiq' if Rails.env.production?
    mount RailsPerformance::Engine => 'app_performance'
    mount PgHero::Engine => 'pg_stats'
  end
end
