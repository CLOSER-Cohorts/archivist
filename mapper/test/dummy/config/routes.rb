Rails.application.routes.draw do
  mount Mapper::Engine => "/mapper"
end
