Rails.application.routes.draw do
  root 'application#index'

  match 'admin/import/instruments', to: 'instruments#import', via: [:post, :put], constraints: {format: ''}

  resources :topics, constraints: -> (r) { (r.format == :json) }

  resources :datasets, shallow: true, constraints: -> (r) { (r.format == :json) } do
    resources :variables
  end

  resources :instruments, constraints: -> (r) { (r.format == :json) } do
    resources :cc_sequences
    resources :cc_statements
    resources :cc_questions
    resources :cc_loops
    resources :cc_conditions
    resources :response_units
    resources :response_domain_datetimes
    resources :response_domain_numerics
    resources :question_grids
    resources :question_items
    resources :instructions
    resources :response_domain_texts
    resources :code_lists
    resources :categories
    member do
      post 'copy', to: 'instruments#copy'
      get 'response_domains', to: 'instruments#response_domains'
      post 'reorder_ccs', to: 'instruments#reorder_ccs'
    end
  end

  get 'studies', to: 'application#studies', constraints: -> (r) { (r.format == :json) }
  get 'stats', to: 'application#stats', constraints: -> (r) { (r.format == :json) }
  match '*path', to: 'application#index', via: :all, constraints: {format: ''}

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
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

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
