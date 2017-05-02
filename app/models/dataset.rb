class Dataset < ApplicationRecord

  has_many :instruments, through: :instruments_datasets
  has_many :instruments_datasets, class_name: 'InstrumentsDatasets'

  has_many :dv_mappings
  has_many :qv_mappings
  has_many :variables, dependent: :destroy

  attr_accessor :var_count

  def dv_count
    self.dv_mappings.count
  end

  def questions
    self.instruments.map(&:cc_questions).flatten
  end

  def qv_count
    self.qv_mappings.count
  end
end
