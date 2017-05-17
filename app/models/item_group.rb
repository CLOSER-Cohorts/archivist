class ItemGroup < ApplicationRecord
  belongs_to :item, polymorphic: true
  belongs_to :root_item, polymorphic: true

  enum group_type: [:similar, :identical]
end
