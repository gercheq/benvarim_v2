Benvarim::Application.routes.draw do

  get "/kurumlar" => 'organizations#index', :as => :organizations
  get "/kurum/ekle" => 'organizations#create', :as => :new_organization
  get "/kurum/:id/duzenle" => 'organizations#edit', :as => :edit_organization
  get "/kurum/:id" => 'organizations#show', :as => :organization
  put '/kurum/:id' => 'organizations#update', :as => :organization

  get '/projeler' => "projects#index", :as => :projects
  post '/projeler' =>  "projects#create", :as => :projects
  get '/proje/yeni' => "projects#new", :as => :new_project
  get '/proje/:id/duzenle' => "projects#edit", :as => :edit_project
  get '/proje/:id' => "projects#show", :as => :project
  put '/proje/:id' => "projects#update", :as => :project
  delete '/proje/:id' => "projects#destroy", :as => :project
  get '/projelerimiz' => 'projects#our_projects', :as => :our_projects

  devise_for :organizations, :skip => [:sessions] do
    get '/kurum/giris' => 'devise/sessions#new', :as => :new_organization_session
    post '/kurum/giris' => 'devise/sessions#create', :as => :organization_session
    get '/kurum/cikis' => 'devise/sessions#destroy', :as => :destroy_organization_session

    post '/kurum' => 'devise/registrations#create', :as => :organization_registration
    put '/kurum' => 'devise/registrations#update', :as => :organization_registration

    get '/kurum/kayit' =>  'registrations#new', :as => :new_organization_registration
    get '/kurum/duzenle' => 'registrations#edit', :as => :edit_organization_registration


  end

  devise_for :organizations

  root :to => "home#index"
  get "home/about"

  get "home/help"

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => "welcome#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
