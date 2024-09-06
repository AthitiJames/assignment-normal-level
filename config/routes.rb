Rails.application.routes.draw do
  root "users#index"
  resources :users, only: [:new, :create, :edit, :update, :index]

  get '/register', to: 'users#new'
end
