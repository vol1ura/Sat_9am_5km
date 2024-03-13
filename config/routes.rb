require 'sidekiq/web'

Rails.application.routes.draw do
  default_url_options host: ENV.fetch('APP_HOST')

  root 'pages#show'
  resources :events, param: :code_name, only: :show do
    get :volunteering, on: :member
  end
  resources :activities, only: %i[index show]
  resources :athletes, only: %i[index show]
  resources :volunteers, only: %i[new edit create update]
  resources :badges, only: %i[index show]
  resources :clubs, only: %i[index show] do
    get :last_week, on: :member
  end
  resources :ratings, only: :index do
    get :results, on: :collection
  end
  resource :user, only: :update
  get '/pages/:page', to: 'pages#show', as: :page
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
        confirmations: 'users/confirmations'
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
      resource :user, only: %i[create update]
      resource :athlete, only: :update
    end
    namespace :parkzhrun do
      resources :athletes, only: :update
      resources :activities, only: :create
    end
  end

  authenticate :user, ->(user) { user.admin? } do
    mount Sidekiq::Web => '/sidekiq' if Rails.env.production?
    mount RailsPerformance::Engine => '/app_performance'
  end
end
