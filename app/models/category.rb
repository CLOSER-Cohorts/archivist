class Category < ApplicationRecord
  belongs_to :instrument
  has_many :codes

  URN_TYPE = 'ca'
  TYPE = 'Category'

  include Exportable

  before_create :no_duplicates

  private
  def no_duplicates
    orig = self.instrument.categories.find_by_label self.label
    unless orig.nil?
      self.id = orig.id
      throw :abort
    end
  end
end
