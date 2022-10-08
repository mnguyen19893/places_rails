Rails.application.routes.draw do
  resources :users, param: :username
  post '/users/login', to: 'users#login'
  post 'password/forgot', to: 'password#forgot'
  post 'password/reset', to: 'password#reset'

  get '/*a', to: 'application#not_found'


end
