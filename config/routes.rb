ActionController::Routing::Routes.draw do |map|
  map.root :controller => 'sessions', :action => 'top'
  
  map.resources :users, :colletion => {
           :rec_confirm               => :get,
           :editor                    => :get,
           :create_before_confirm     => :post,
           :user_complete             => :get,
           :update_before_confirm     => :post,
           :recipient_edit            => :get,
           :rec_update_before_confirm => :post,
           :recipient_create          => :post,
           :recipient_complete        => :get,
           :add_recipient             => :post,
  }

  map.resources :recipients, :colletion => {
           :editor => :get,
  }

  map.logout    '/logout',                    :controller => 'sessions', :action => 'destroy'
  map.login     '/login',                     :controller => 'sessions', :action => 'new'
  map.register  '/register',                  :controller => 'org/organizations',    :action => 'create'
  map.signup    '/signup',                    :controller => 'org/organizations',    :action => 'new'
  map.activate  '/activate/:activation_code', :controller => 'org/organizations',    :action => 'activate'

  map.resources :groups, :collection => {
              :create_before_confirm => :post,
              :update_before_confirm => [:post, :get],
  }

  map.resource :session

  map.resources :sessions, :collection => {
           :select_org      => :get,
           :rcnum           => :get,
           :user_num_check  => :get,
      },     :member => {
  }
  
  map.namespace "org" do |organization|
    organization.resources  :organizations, :collection => {
           :create_before_confirm     => :post,
           :update_before_confirm     => [:post, :get],
           :complete_after_create     => :get,
           :complete                  => :get,
           :org_stop                  => [:post, :get],
           :org_list                  => [:post, :get],
           :sadmin_stop_or_restart    => :get,
           :decide_complete           => [:post, :get],
           :decide_create_complete    => [:post, :get],
           :account_change            => [:post, :get],
           :change_before_confirm     => :post,
           :create_and_change_account => :get,
           :super_admin_dissolve      => [:post, :get],
           :rec_url                   => :get,
           :user_url                  => :get,
           :sadmin_org_show           => :get,
    }, :member => {
           :dissolve                  => [:post, :get],
    }
    organization.resources :groups, :collection => {
           :delete                => :get,
    }
    organization.resources :sentences, :collection => {
           :delete       => :get,
           :insert_list  => :get,
           :detail       => :get,
    }
    organization.resources :administrators, :collection => {
           :create_before_confirm => :post,
           :update_before_confirm => :post,
           :delete_admin          => :get,
    }
    organization.resources :users, :collection => {
           :rec_confirm               => :get,
           :editor                    => :get,
           :create_before_confirm     => :post,
           :user_complete             => :get,
           :update_before_confirm     => :post,
           :recipient_edit            => :get,
           :rec_update_before_confirm => :post,
           :recipient_create          => :post,
           :recipient_complete        => :get,
           :add_recipient             => :post,
      }, :member => {
    }
    organization.resources :recipients, :collection => {
           :detail                => :get,
           :create_before_confirm => :post,
           :update_before_confirm => :post,
           :recipient_complete    => :get,
           :editor                => [:post, :get],
           :dissolve              => :get,
           :decide_dissolve       => :get,
           :dissolve_complete     => :get,
           :number_check          => :get,
           :number_confirm        => [:post, :get],
           :editor_user           => :get,
           :user_up_before_confirm => :get,
           :user_up => :get,
      }, :member => {
    }
    organization.namespace "useradmin" do |useradmin|
      useradmin.resources  :users, :collection => {
           :search                => :get,
           :select_user           => :get,
           :create_before_confirm => :post,
           :update_before_confirm => :post,
           :user_complete         => :get,
           :detail                => [:post, :get],
           :after_detail          => [:post, :get],
           :delete                => :get,
           :csv                   => :get,
           :out_ads_csv           => :get,
      }, :member => {
           :user_complete         => :get,
      }
      useradmin.resources :csv_imports, :collection => {
          :complete              => :get,
          :template_downloadable => :get
      }
      useradmin.resources :groups, :collection => {
           :search_users  => [:get, :post],
      }

      useradmin.resources  :recipients, :collection => {
           :create_before_confirm => :post,
           :update_before_confirm => :post,
           :recipient_complete    => :get,
           :detail                => [:post, :get],
           :delete                => :get,
           :dissolve              => :get,
      }, :member => {
           :editor => :get,
      }
    end
    organization.namespace "sendmail" do |sendmail|
      sendmail.resources  :mail_summaries, :collection => {
           :create_before_confirm      => :post,
           :update_before_confirm      => :post,
           :create_body_before_confirm => [:post, :get],
           :update_body_before_confirm => [:post, :get],
           :delete                     => :get,
           :get_answer                 => :get,
           :editor                     => :get,
           :search                     => :get,
           :detail_error               => :get,
      }, :member => {
           :detail                     => :get,
     }
    end

  end

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
  # map.root :controller => "welcome"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing or commenting them out if you're using named routes and resources.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
