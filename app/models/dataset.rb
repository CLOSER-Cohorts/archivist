class Dataset < ApplicationRecord

  has_many :instruments, through: :instruments_datasets
  has_many :instruments_datasets, class_name: 'InstrumentsDatasets'

  has_many :dv_mappings
  has_many :qv_mappings
  has_many :variables, dependent: :destroy

  attr_accessor :var_count

  def questions
    self.instruments.map(&:cc_questions).flatten
  end
end
