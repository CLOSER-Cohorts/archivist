# A representation of the database view for DV Mapping
#
# === Properties
# * id
# * source
# * variable
class DvMapping < ActiveRecord::Base
  # Use id as a primary key
  self.primary_key = :id

  # Each DV mapping can only belong to one {Dataset}
  belongs_to :dataset
end