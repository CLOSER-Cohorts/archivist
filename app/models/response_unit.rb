class ResponseUnit < ActiveRecord::Base
  has_many :questions, class_name: 'CcQuestion'
end
