class Map < ApplicationRecord
  belongs_to :source, polymorphic: true
  belongs_to :variable
end
