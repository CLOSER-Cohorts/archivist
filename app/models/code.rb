class Code < ActiveRecord::Base
  belongs_to :code_list
  belongs_to :category

  def label
    self.category.nil? ? nil : self.category.label
  end

  def label=(val)
    set_label(val, code_list.instrument_id)
  end

  def set_label(val, instrument_id)
    self.category = Category.find_by label: val, instrument_id: instrument_id
    if self.category.nil?
      self.category = Category.create label: val, instrument: instrument_id
    end
  end
end
