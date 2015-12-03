class CcQuestion < ActiveRecord::Base
  belongs_to :question, polymorphic: true
end
