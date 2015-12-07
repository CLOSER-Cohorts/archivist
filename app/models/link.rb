class Link < ActiveRecord::Base
  belongs_to :target, polymorphic: true
  belongs_to :topic
end
