class Category < ApplicationRecord
  belongs_to :instrument
  has_many :codes

  URN_TYPE = 'ca'
  TYPE = 'Category'

  include Exportable
end
