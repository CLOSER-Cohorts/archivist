# This serves as a junction model to allow many-to-many
# relations between {Instrument Instruments} and {Dataset Datasets}
#
# These connections only serve to scope Mapping work and do *not*
# represent a logical link.
class InstrumentsDatasets < ApplicationRecord
  # Joining {Instrument}
  belongs_to :instrument
  # Joining {Dataset}
  belongs_to :dataset
end
