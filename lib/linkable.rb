module Linkable
  extend ActiveSupport::Concern
  included do
    has_one :link, as: :target, dependent: :destroy
    has_one :topic, through: :link
  end
end