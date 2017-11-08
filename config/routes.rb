Rails.application.routes.draw do

  match	':controller(/:action(/:id))',	:via	=>	:get
  match	':controller(/:action(/:id))',	:via	=>	:post

  get 'spending_history/charts' => "spending_history"

  get 'spending_history/index' => "spending_history#index"

  get 'recommendations/index' => "recommendations#index"


  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  #resources :admin
  #resources :home
  #resources :access

  get "access/login" => "access#login"
  post "access/attempt_login" => "access#attempt_login"
  post "access/sign_up" => "access#sign_up"
  post "access/logout" => "access#logout"

  get "admin/index" => "admin#index"
  get "admin/show" => "admin#show"
  get "admin/new_admin" => "admin#new_admin"
  post "admin/create_admin" => "admin#create_admin"
  get "admin/delete" => "admin#delete"
  post "admin/destroy" => "admin#destroy"
  get "admin/edit" => "admin#edit"
  post "admin/make_edit" => "admin#make_edit"

  get "home/index" =>"home#index"


  root 'access#login'
  match ":controller(/:action(/:id))", :via => [:get, :post]

end
