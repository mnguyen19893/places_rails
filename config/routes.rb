Rails.application.routes.draw do
  # Places routes
  get "/places/:id/like", to: "places#like", as: "place_like", constraints: { id: /\d+/ }
  get "/places/mine", to: "places#mine", as: "place_mine", constraints: {}
  get "/places/liked", to: "places#liked", as: "place_liked", constraints: {}
  get "/places/get_type", to: "places#get_type", as: "place_get_type", constraints: {}

  resources :places, only: [:index, :show, :create, :destroy, :update]
  resources :device_info, only: [:create]



  # Users routes
  resources :users, param: :username
  post '/users/login', to: 'users#login'
  post 'password/forgot', to: 'password#forgot'
  post 'password/reset', to: 'password#reset'

  #get '/*a', to: 'application#not_found'


end
