class Grouping < ApplicationRecord
  belongs_to :item_group
  belongs_to :item, polymorphic: true
end
