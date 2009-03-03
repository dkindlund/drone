ActionController::Routing::Routes.draw do |map|

  map.resources :applications, :active_scaffold => true
  map.resources :clients, :active_scaffold => true
  map.resources :client_statuses, :active_scaffold => true
  map.resources :configurations, :active_scaffold => true
  map.resources :file_contents, :active_scaffold => true
  map.resources :fingerprints, :active_scaffold => true
  map.resources :hosts, :active_scaffold => true
  map.resources :job_alerts, :active_scaffold => true
  map.resources :jobs, :active_scaffold => true
  map.resources :job_sources, :active_scaffold => true
  map.resources :os, :active_scaffold => true
  map.resources :os_processes, :active_scaffold => true
  map.resources :process_files, :active_scaffold => true
  map.resources :process_registries, :active_scaffold => true
  map.resources :urls, :active_scaffold => true
  map.resources :url_statistics, :active_scaffold => true
  map.resources :url_statuses, :active_scaffold => true

  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  map.root :controller => "dashboard"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing the them or commenting them out if you're using named routes and resources.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
