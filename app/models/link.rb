class Link < ApplicationRecord
  belongs_to :target, polymorphic: true
  belongs_to :topic
end
