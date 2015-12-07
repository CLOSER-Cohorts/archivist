class Code < ActiveRecord::Base
  belongs_to :code_list
  belongs_to :category

  def label
    category.nil? ? nil : category.label
  end

  def label=(val)
    category = Category.find_by_label(val)
    if category.nil?
      category = Category.create label: val, instrument: code_list.instrument
    end
  end
end
