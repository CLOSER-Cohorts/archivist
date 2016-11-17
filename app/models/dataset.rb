class Dataset < ApplicationRecord
  has_many :variables, dependent: :destroy

  has_many :instruments_datasets, class_name: 'InstrumentsDatasets'
  has_many :instruments, through: :instruments_datasets
end
