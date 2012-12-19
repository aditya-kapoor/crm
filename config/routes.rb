Crm::Application.routes.draw do
  # devise_for :admins, :skip => [:sessions]

  devise_for :admins, :controllers => { :registrations => "registrations"}
  #, :path => '', :path_names => { :sign_in => 'login', :sign_out => 'logout', :sign_up => 'register' }

  resources :customers do 
    collection do 
      post "export_to_csv"
      get "get_results"
      post "merge_contacts"
      get "merge_contacts"
      post "merge_and_save_contacts"
      get "upload_csv"
      post "import_csv"
      post "save_csv_contents"
      get "start_merge_contacts"
    end
  end

  # resources :sessions do 
  #   get "logout", :on => :collection
  # end

  # namespace :admin do
  resources :admin do
    get "add_new_admin", :on => :collection
    post "save_new_admin", :on => :collection
  end
  # end

  root :to => 'customers#index'
end
