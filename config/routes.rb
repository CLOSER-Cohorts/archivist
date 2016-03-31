Rails.application.routes.draw do
  root 'application#index'

  match 'admin/import/instruments', to: 'instruments#import', via: [:post, :put], constraints: {format: ''}

  resources :topics, constraints: -> (r) { (r.format == :json) } do
    collection do
      get 'nested_index', to: 'topics#nested_index'
      get 'flattened_nest', to: 'topics#flattened_nest'
    end
  end

  resources :datasets, constraints: -> (r) { (r.format == :json) } do
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
end
