Recipes::Application.routes.draw do
  root "pages#home"
  resources :users
  resources :sessions
  resources :ingredients
  resources :fridges
  resources :recipes

  get "/logout" => "sessions#destroy", as: "logout"
  patch "/fridges" => "fridges#update"
  patch "/recipes" => "recipes#update"
  post "/recipes/search" => "recipes#search"
end
