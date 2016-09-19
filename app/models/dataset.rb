class Dataset < ActiveRecord::Base
  has_many :variables, dependent: :destroy

  has_many :instruments_datasets, class_name: 'InstrumentsDatasets'
  has_many :instruments, through: :instruments_datasets

  attr_accessor :var_count
end
