Rails.application.routes.draw do
  root 'pages#show'
  resources :events, param: :code_name, only: :show
  resources :activities, only: %i[index show]
  resources :athletes, only: %i[index show]
  get '/pages/:page', to: 'pages#show', as: :page
  devise_for :users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
end
