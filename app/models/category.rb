class Category < ApplicationRecord
  belongs_to :instrument

  URN_TYPE = 'ca'
  TYPE = 'Category'

  include Exportable
end
