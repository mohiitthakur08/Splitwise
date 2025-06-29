Rails.application.routes.draw do
  devise_for :users
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  root to: "static#dashboard"
  resources :expenses, only: [:new, :create, :index, :destroy]
  post 'expenses/settle_up', to: 'expenses#settle_up', as: 'settle_up_expenses'
  get '/dashboard', to: 'static#dashboard'
  get '/people/:id', to: 'static#person', as: :person
  
  resource :profile, only: [:show, :edit, :update], controller: 'users'


end
