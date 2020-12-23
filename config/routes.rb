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
        post 'lock', to: 'admin#lock'
        delete 'delete', to: 'admin#destroy'
      end
    end
  end

  match 'admin/import/instruments', to: 'instruments#import', via: [:post, :put], constraints: {format: ''}
  match 'admin/import/datasets', to: 'datasets#import', via: [:post, :put], constraints: {format: ''}

  # adding a route.
  match 'admin/import/datasets',    to: 'datasets#import', via: [:post, :put], constraints: {format: 'json'}

  request_processor = lambda do |request|
    [:json, :xml, :text].include?(request.format.symbol)
  end

  resources :topics, constraints: request_processor do
    collection do
      get 'nested_index', to: 'topics#nested_index'
      get 'flattened_nest', to: 'topics#flattened_nest'
    end
    member do
      get 'question_statistics', to: 'topics#question_statistics'
      get 'variable_statistics', to: 'topics#variable_statistics'
    end
  end

  resources :user_groups, constraints: -> (r) { (r.format == :json) } do
    collection do
      get 'external'
    end
  end

  resources :datasets, constraints: request_processor do
    resources :variables do
      member do
        post 'set_topic', to: 'variables#set_topic'
        post 'add_sources', to: 'variables#add_sources'
        post 'remove_source', to: 'variables#remove_source'
      end
    end
    member do
      match 'imports', to: 'datasets#member_imports', via: [:post, :put]
      get 'questions', to: 'datasets#questions'
      get 'dv', to: 'datasets#dv'
    end
    resources :imports, module: :datasets, only: [:index, :show]
  end
  get 'datasets/:dataset_id/tv', to: 'variables#tv', constraints: request_processor

  resources :instruments, constraints: request_processor do
    resources :cc_sequences do
      member do
        post 'set_topic', to: 'cc_sequences#set_topic'
      end
    end
    resources :cc_statements
    resources :cc_questions do
      member do
        get 'variables', to: 'cc_questions#variables'
        post 'add_variables', to: 'cc_questions#add_variables'
        post 'remove_variable', to: 'cc_questions#remove_variable'
        post 'set_topic', to: 'cc_questions#set_topic'
        delete 'delete', to: 'cc_questions#remove_variable'
      end
    end
    resources :cc_loops do
      member do
        post 'set_topic', to: 'cc_loops#set_topic'
      end
    end
    resources :cc_conditions do
      member do
        post 'set_topic', to: 'cc_conditions#set_topic'
      end
    end
    resources :response_units
    resources :response_domain_datetimes
    resources :response_domain_numerics
    resources :question_grids
    resources :question_items
    resources :instructions
    resources :response_domain_texts
    resources :code_lists
    resources :categories
    resources :imports, module: :instruments, only: [:index, :show]
    member do
      post 'copy/:new_prefix', to: 'instruments#copy', as: :copy
      get 'clear_cache', to: 'instruments#clear_cache'
      get 'response_domains', to: 'instruments#response_domains'
      get 'response_domain_codes', to: 'instruments#response_domain_codes'
      post 'reorder_ccs', to: 'instruments#reorder_ccs'
      get 'stats', to: 'instruments#stats'
      get 'export', to: 'instruments#export'
      get 'mapper', to: 'instruments#mapper'
      get 'qv', to: 'instruments#mapping'

      match 'imports', to: 'instruments#member_imports', via: [:post, :put]
      get 'variables', to: 'instruments#variables'
    end
  end
  resources :imports, only: [:index, :show]
  get 'instruments/:id/mapping', to: redirect('/instruments/%{id}/qv')
  get 'instruments/:instrument_id/tq', to: 'cc_questions#tq', constraints: request_processor

  get 'instruments/:id/export/:doc_id', to: 'instruments#document'
  get 'instruments/:id/export', to: 'instruments#latest_document'
  get 'datasets/:id/export', to: 'datasets#latest_document'

  get 'studies', to: 'main#studies', constraints: -> (r) { (r.format == :json) }
  get 'stats', to: 'main#stats', constraints: -> (r) { (r.format == :json) }

  get '*path', to: "fallback#index", constraints: ->(request) do
    !request.xhr? && request.format.html?
  end

  # authenticated :user do
  #   root 'main#index', to: 'instruments#index',  as: :authenticated_root
  # end

  root 'fallback#index'
end
