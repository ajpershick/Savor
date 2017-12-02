Rails.application.routes.draw do
  # resources :admin
  # resources :home
  # resources :access

  post 'account_balance/update'
  get 'account_balance/index'

  get 'input/new'
  get "input/income"
  post "input/create_income"

  get 'history/index'
  get 'history/income'

  match	':controller(/:action(/:id))',	:via	=>	:get
  match	':controller(/:action(/:id))',	:via	=>	:post

  get 'maps/index' => "maps#index"

  root 'home#index'

  get "access/login" => "access#login"
  post "access/attempt_login" => "access#attempt_login"
  post "access/sign_up" => "access#sign_up"
  post "access/logout" => "access#logout"

  get "admin/index" => "admin#index"
  get "admin/show" => "admin#show"
  get "admin/new_user" => "admin#new_user"
  post "admin/create_user" => "admin#create_user"
  get "admin/delete" => "admin#delete"
  post "admin/destroy" => "admin#destroy"
  get "admin/edit" => "admin#edit"
  get "admin/confirm_edit" => "admin#confirm_edit"
  post "admin/make_edit" => "admin#make_edit"

  get 'account/edit'
  post 'account/make_edit'
  get 'account/index'
  get 'account/change_password'
  post 'account/make_password_change'

  get 'bank_sync/index'
  get 'bank_sync/create_item'
  get 'bank_sync/add_account'
  post 'bank_sync/get_access_token'
  post 'bank_sync/delete_access_token'
  post 'bank_sync/create_bank_account'
  get 'bank_sync/get_bank_account_info'
  get 'bank_sync/get_account_balance'
  get 'bank_sync/get_transaction'
  get 'bank_sync/show_depository_accounts'

  get "home/index" =>"home#index"

  match '/get_access_token' => 'bank_sync#get_access_token', via: :post


  root 'access#login'
  match ":controller(/:action(/:id))", :via => [:get, :post]

end
