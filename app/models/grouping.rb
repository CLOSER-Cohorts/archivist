# frozen_string_literal: true

# Forms a connection between a groupable item and a group
#
# This is a junction model to form a many-to-many between items
# and {ItemGroup groups}
class Grouping < ApplicationRecord
  # Each grouping much belong to an {ItemGroup}
  belongs_to :item_group

  # Each grouping belongs to one item, which can be of any type
  belongs_to :item, polymorphic: true
end
