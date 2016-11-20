Mapper::Engine.routes.draw do
  resources :datasets, constraints: -> (r) { (r.format == :json || r.format == :xml) } do
    resources :variables
  end
end
