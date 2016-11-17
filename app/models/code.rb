class Code < ApplicationRecord
  belongs_to :code_list
  belongs_to :category
  belongs_to :instrument

  before_create :set_instrument

  include Exportable

  URN_TYPE = 'co'
  TYPE = 'Code'

  def label
    self.category.nil? ? nil : self.category.label
  end

  def label=(val)
    set_label(val, code_list.instrument)
  end

  def set_label(val, instrument)
    self.category = Category.find_by label: val, instrument_id: instrument.id
    if self.category.nil?
      self.category = Category.create label: val, instrument: instrument
    end
  end

  def set_instrument
    self.instrument_id = self.code_list.instrument_id
  end
end
