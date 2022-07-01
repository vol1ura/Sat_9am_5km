Rails.application.routes.draw do
  root 'statics#index'
  resources :activities
  resources :athletes, only: %i[index show]
  resources :events, param: :code_name, only: %i[index show]
  get '/about', to: 'statics#about'
  get '/rules', to: 'statics#rules'
  get '/support', to: 'statics#support'
  get '/join', to: 'statics#join'
  devise_for :users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
end
