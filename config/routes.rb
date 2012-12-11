Crm::Application.routes.draw do
  resources :customers do 
    post "export_to_csv", :on => :collection
    get "get_results", :on => :collection
  end

  resources :sessions do 
    get "logout", :on => :collection
  end

  # namespace :admin do
  resources :admin
  # end

  root :to => 'admin#index'
end
