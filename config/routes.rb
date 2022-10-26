Rails.application.routes.draw do
  # Places routes
  # get 'places/index'
  # get 'places/show'
  resources :places, only: [:index, :show]

  get "/places/:id/like", to: "places#like", as: "company", constraints: { id: /\d+/ }

  # Users routes
  resources :users, param: :username
  post '/users/login', to: 'users#login'
  post 'password/forgot', to: 'password#forgot'
  post 'password/reset', to: 'password#reset'

  get '/*a', to: 'application#not_found'


end
