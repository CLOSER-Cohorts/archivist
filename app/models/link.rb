# A junction model to join {Topic Topics} to a linkable items
class Link < ApplicationRecord
  # The linkable item
  # targets can be a Variable or a CcQuestion
  belongs_to :target, polymorphic: true

  # The topic
  belongs_to :topic
end
