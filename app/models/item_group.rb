class ItemGroup < ApplicationRecord
  has_many :groupings
  has_many :items, through: :groupings, source: :item, source_type: 'Variable'
  belongs_to :root_item, polymorphic: true

  enum group_type: [:similar, :identical]

  def items
    class << self
      def +(other)

      end
    end
  end
end
