class ResponseUnit < ApplicationRecord
  belongs_to :instrument
  has_many :questions, class_name: 'CcQuestion', inverse_of: :response_unit
end
