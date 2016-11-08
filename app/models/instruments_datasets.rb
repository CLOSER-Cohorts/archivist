class InstrumentsDatasets < ApplicationRecord
  belongs_to :instrument
  belongs_to :dataset
end
