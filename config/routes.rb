Rails.application.routes.draw do
  root "users#index"
  resources :users, only: [:new, :create]

  get '/register', to: 'users#new'
end
