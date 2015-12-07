class Map < ActiveRecord::Base
  belongs_to :source, polymorphic: true
  belongs_to :variable
end
