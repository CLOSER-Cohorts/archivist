class Topic < ApplicationRecord
  belongs_to :parent, class_name: 'Topic'
  has_many :children, class_name: 'Topic', foreign_key: :parent_id, dependent: :destroy
end
