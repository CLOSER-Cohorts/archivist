class ResponseUnit < ActiveRecord::Base
  belongs_to :instrument
  has_many :questions, class_name: 'CcQuestion'
end
