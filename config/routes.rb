Rails.application.routes.draw do
  get 'welcome/index'

  get 'welcome/subpage'

  match	':controller(/:action(/:id))',	:via	=>	:get
  match	':controller(/:action(/:id))',	:via	=>	:post

  root 'welcome#index'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
