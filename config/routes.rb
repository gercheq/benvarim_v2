Benvarim::Application.routes.draw do
  get "admin/impersonate"



  get "/sitemap" => "sitemap#index", :as => :sitemap



  post "iletisim" => "contact_forms#create", :as => :new_contact_form
  get "iletisim/yeni" => "contact_forms#new", :as => :new_contact_form
  get "iletisim" => "contact_forms#index", :as => :contact_forms

  get "/nasil_calisir" => "home#nasil_calisir", :as => :nasil_calisir
  get "/nedir" => "home#nedir", :as => :nedir
  get "/iletisim" => "home#iletisim", :as => :iletisim

  # STATIK SAYFALAR
  get "/sik_sorulan_sorular" => "home#sik_sorulan_sorular", :as => :sik_sorulan_sorular
  get "/kullanim_sartlari" => "home#kullanim_sartlari", :as => :kullanim_sartlari
  get "/guvenli_odeme" => "home#guvenli_odeme", :as => :guvenli_odeme
  get "/hakkimizda" => "home#hakkimizda", :as => :hakkimizda
  get "/gizlilik_politikasi" => "home#gizlilik_politikasi", :as => :gizlilik_politikasi
  get "/kariyer" => "home#kariyer", :as => :kariyer
  get "/basinda_benvarim" => "home#basinda_benvarim", :as => :basinda_benvarim




  # ORNEK STATIK SAYFALAR - ILERLEYEN DONEMLERDE ENTEGRE EDILECEK
  get "/bagis_sayfasi" => "home#bagis_sayfasi", :as => :bagis_sayfasi
  get "/kurum_sayfasi" => "home#kurum_sayfasi", :as => :kurum_sayfasi

  get "/sayfalar" => "pages#index", :as => :pages
  get "/sayfalar" => "pages#index", :as => :all_pages#sometimes necessary :/
  post "/sayfa/kaydet" => "pages#create", :as => :pages
  get "/sayfa/yeni" => "pages#new", :as => :new_page
  get "/proje/:project_id/yeni_sayfa" => "pages#new", :as => :new_page_for_project
  get "/kurum/:organization_id/yeni_sayfa" => "pages#new", :as => :new_page_for_organization
  get "/sayfa/:id/duzenle" => "pages#edit", :as => :edit_page
  get "/sayfa/:id" => "pages#show", :as => :page
  put "/sayfa/:id" => "pages#update",  :as => :page
  get "/sayfalarim" => "pages#my_pages", :as => :my_pages
  get "/bagislar/:id/:start" => "pages#partial_payments", :as => :partial_payments

  post '/bagis/kontrol' => 'payments#ipn_handler' , :as => :paypal_ipn

  get '/sayfa/:page_id/bagis' => "payments#new", :as => :donate_for_page
  get '/kurum/:organization_id/bagis' => "payments#new", :as => :donate_for_organization
  get '/proje/:project_id/bagis' => "payments#new", :as => :donate_for_project

  post '/sayfa/:page_id/bagis' => "payments#create", :as => :donate_for_page
  post '/kurum/:organization_id/bagis' => "payments#create", :as => :donate_for_organization
  post '/proje/:project_id/bagis' => "payments#create", :as => :donate_for_project

  get '/sayfa/:page_id/bagis?popup=1' => "payments#new", :as => :donate_popup_for_page
  get '/kurum/:organization_id/bagis?popup=1' => "payments#new", :as => :donate_popup_for_organization
  get '/proje/:project_id/bagis?popup=1' => "payments#new", :as => :donate_popup_for_project

  get '/bagis/tamamla' => "payments#finalize", :as => :finalize_donation
  get '/sayfa/:page_id/bagis/tamamla' => "payments#finalize", :as => :finalize_donation_for_page
  get '/proje/:project_id/bagis/tamamla' => "payments#finalize", :as => :finalize_donation_for_project
  get '/kurum/:organization_id/bagis/tamamla' => "payments#finalize", :as => :finalize_donation_for_organization
  get '/proje/:id' => "projects#show", :as => :project


  devise_for :users, :skip => [:sessions], :controllers => { :omniauth_callbacks => "omniauth_callbacks" } do
    get '/gonullu/giris' => 'devise/sessions#new', :as => :new_user_session
    post '/gonullu/giris' => 'devise/sessions#create', :as => :user_session
    get '/gonullu/cikis' => 'devise/sessions#destroy', :as => :destroy_user_session

    post '/gonullu' => 'devise/registrations#create', :as => :user_registration
    put '/gonullu' => 'devise/registrations#update', :as => :user_registration

    get '/gonullu/kayit' =>  'devise/registrations#new', :as => :new_user_registration
    get '/gonullu/duzenle' => 'devise/registrations#edit', :as => :edit_user_registration
  end


  get "/gonullu/:id" => "users#show", :as => :user
  get "/gonullu/:id/duzenle" => "users#edit", :as => :edit_user
  put '/gonullu/:id' => 'users#update', :as => :user
  get '/ben' => 'users#me', :as => :user_root


  get '/projeler' => "projects#index", :as => :projects
  post '/projeler' =>  "projects#create", :as => :projects
  get '/proje/yeni' => "projects#new", :as => :new_project
  get '/proje/:id/duzenle' => "projects#edit", :as => :edit_project
  get '/proje/:id' => "projects#show", :as => :project
  put '/proje/:id' => "projects#update", :as => :project
  delete '/proje/:id' => "projects#destroy", :as => :project
  get 'kurum/:id/projeler' => 'projects#by_organization',  :as => :organization_projects
  get 'kurum/:organization_id/proje/yeni' => 'projects#new',  :as => :new_project_for_organization

  get '/kurumlar' => "organizations#index", :as => :organizations
  get '/kurumlar' => "organizations#index", :as => :all_organizations
  post '/kurum' =>  "organizations#create", :as => :organizations
  get '/kurum/yeni' => "organizations#new", :as => :new_organization
  get '/kurum/:id/duzenle' => "organizations#edit", :as => :edit_organization
  get '/kurum/:id' => "organizations#show", :as => :organization
  put '/kurum/:id' => "organizations#update", :as => :organization
  get 'kurum/:id/projeler' => 'projects#by_organization',  :as => :organization_projects

  # search page
  get 'ara' => "search#index", :as => :search
  get 'ara/d/:id' => "search#id_redirect", :as => :search_result_redirect

  # ADMIN PAGES
  get '/kertenkele' => "admin#index", :as => :admin
  post '/kertenkele/kurum/:id/duzenle' => "admin#edit_organization", :as => :admin_edit_organization
  get '/kertenkele/impersonate' => "admin#impersonate", :as => :admin_impersonate
  post '/kertenkele/impersonate' => "admin#impersonate", :as => :admin_impersonate
  get '/kertenkele/kurumlar' => "admin#organizations", :as => :admin_organizations



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
