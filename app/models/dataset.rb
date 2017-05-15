# The Dataset is based on the DataSet model from DDI3.X and is one of the
# champion models that pulls together Archivist.
#
#
# Please visit http://www.ddialliance.org/Specification/DDI-Lifecycle/3.2/XMLSchema/FieldLevelDocumentation/schemas/dataset_xsd/elements/DataSet.html
#
# === Properties
# * Name
# * DOI
# * Filename
# * Study
class Dataset < ApplicationRecord
  # This model can be tracked using an Identifier
  include Identifiable

  # A Dataset can have many {Instrument Instruments} through a many-to-many relationship
  has_many :instruments, through: :instruments_datasets

  # The junction model for the many-to-many relationship with {Instrument Instruments}
  has_many :instruments_datasets, class_name: 'InstrumentsDatasets'

  # Each Dataset has many DV mappings
  has_many :dv_mappings

  # Each Dataset has many Q-V mappings
  has_many :qv_mappings

  # A Dataset can have many {Variable Variables}
  has_many :variables, dependent: :destroy

  # Make var_count both get-able and set-able
  attr_accessor :var_count

  # Returns the number of DV mappings for within this Dataset
  #
  # @return [Integer]
  def dv_count
    self.dv_mappings.count
  end

  # Returns a list off all possible {CcQuestion questions} for mapping to
  #
  # @return [Array]
  def questions
    self.instruments.map(&:cc_questions).flatten
  end

  # Returns the number of Q-V mappings using variables from this Dataset
  #
  # @return [Integer]
  def qv_count
    self.qv_mappings.count
  end
end
