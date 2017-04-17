Rails.application.routes.draw do
  post 'setup', to: 'main#setup'

  as :user do
    patch '/users/confirmation' => 'users/confirmations#update', :via => :patch, :as => :update_user_confirmation
  end
  devise_for :users, controllers: {
      sessions: 'users/sessions',
      confirmations: 'users/confirmations',
      passwords: 'users/passwords',
      registrations: 'users/registrations',
      unlocks: 'users/unlocks',
  }
  namespace :users do
    resources :admin, constraints: -> (r) { (r.format == :json) } do
      member do
        post 'password', to: 'admin#reset_password'
      end
    end
  end
  root 'main#index'

  match 'admin/import/instruments', to: 'instruments#import', via: [:post, :put], constraints: {format: ''}
  match 'admin/import/datasets', to: 'datasets#import', via: [:post, :put], constraints: {format: ''}

  # adding a route.
  match 'admin/import/datasets',    to: 'datasets#import', via: [:post, :put], constraints: {format: 'json'}

  resources :topics, constraints: -> (r) { (r.format == :json) } do
    collection do
      get 'nested_index', to: 'topics#nested_index'
      get 'flattened_nest', to: 'topics#flattened_nest'
    end
  end

  resources :groups, constraints: -> (r) { (r.format == :json) } do
    collection do
      get 'external'
    end
  end
  resources :datasets, constraints: -> (r) { (r.format == :json || r.format == :xml) } do
    resources :variables do
      member do
        post 'set_topic', to: 'variables#set_topic'
        post 'add_source', to: 'variables#add_source'
        post 'remove_source', to: 'variables#remove_source'
      end
    end
    member do
      match 'imports', to: 'datasets#member_imports', via: [:post, :put]
      get 'questions', to: 'datasets#questions'
    end
  end

  request_processor = lambda do |request|
    # binding.pry if request.path =~ %r{/instruments/13/imports}
    # 1
    [:json, :xml, :text].include?(request.format.symbol)
  end

  resources :instruments, constraints: request_processor do
    resources :cc_sequences
    resources :cc_statements
    resources :cc_questions do
      member do
        get 'variables', to: 'cc_questions#variables'
        post 'add_variables', to: 'cc_questions#add_variables'
        post 'remove_variable', to: 'cc_questions#remove_variable'
      end
    end
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
      post 'copy/:new_prefix', to: 'instruments#copy'
      get 'response_domains', to: 'instruments#response_domains'
      get 'response_domain_codes', to: 'instruments#response_domain_codes'
      post 'reorder_ccs', to: 'instruments#reorder_ccs'
      get 'stats', to: 'instruments#stats'
      get 'export', to: 'instruments#export'
      get 'mapper', to: 'instruments#mapper'
      match 'imports', to: 'instruments#member_imports', via: [:post, :put]
      get 'variables', to: 'instruments#variables'
    end
  end

  get 'instruments/:id/export', to: 'instruments#latest_document'
  get 'datasets/:id/export', to: 'datasets#latest_document'

  get 'clusters/:class/:id', to: 'clusters#show', constraints: -> (r) { (r.format == :json || r.format == :xml) }

  get 'studies', to: 'main#studies', constraints: -> (r) { (r.format == :json) }
  get 'stats', to: 'main#stats', constraints: -> (r) { (r.format == :json) }
  match '*path', to: 'main#index', via: :all, constraints: {format: ''}
end
