class CcQuestion < ActiveRecord::Base
  include Construct
  include Linkable
  belongs_to :question, polymorphic: true
  belongs_to :response_unit
  has_many :maps, as: :source
  has_many :variables, through: :maps
end
