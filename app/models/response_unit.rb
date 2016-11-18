class ResponseUnit < ApplicationRecord
  belongs_to :instrument
  has_many :questions, class_name: 'CcQuestion'
end
