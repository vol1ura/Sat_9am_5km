Rails.application.routes.draw do
  root 'pages#show'
  resources :events, param: :code_name, only: :show do
    get :volunteering, on: :member
  end
  resources :activities, only: %i[index show]
  resources :athletes, only: %i[index show]
  resources :clubs, only: %i[index show]
  resources :badges, only: %i[index show]
  resources :volunteers, only: %i[new edit create update]
  resource :user, only: %i[create update]
  get '/pages/:page', to: 'pages#show', as: :page
  get '/top_results', to: 'results#top'
  devise_for :users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
end
