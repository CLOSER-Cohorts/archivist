class RdsQs < ActiveRecord::Base
  belongs_to :response_domain, polymorphic: true
  belongs_to :question, polymorphic: true
end
