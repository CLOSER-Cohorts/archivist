class InstrumentsDatasets < ActiveRecord::Base
  belongs_to :instrument
  belongs_to :dataset
end
