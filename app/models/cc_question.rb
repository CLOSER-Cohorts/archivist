class CcQuestion < ActiveRecord::Base
  include Construct
  belongs_to :question, polymorphic: true
  belongs_to :response_unit
end
