# A generic model to represent an DDI 3.X support item group
# e.g. VariableGroup
#
# An ItemGroup can also be purposed to represent groups with
# a root item.
#
# === Properties
# * Label
# * Group type
# * Item type
class ItemGroup < ApplicationRecord
  # Groupings are the junction model to join items to the group
  has_many :groupings

  # This should be a list of items belonging to a group, but is hard-typed to Variables atm
  has_many :items, through: :groupings, source: :item, source_type: 'Variable'

  # Groups can have an optional root item, e.g. a topic
  belongs_to :root_item, polymorphic: true

  # Currently only similar and identical item groups are supported, for harmonisation work
  enum group_type: [:similar, :identical]

  # Partially implemented system to manage items with dynamic types
  def items
    class << self
      def +(other)

      end
    end
  end
end
