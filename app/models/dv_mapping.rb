# A representation of the database view for DV Mapping
#
# This cannot be used for creating, updating or deleting, but provides
# a quick way to view derived variable mapping.
#
# === Properties
# * id
# * source
# * variable
class DvMapping < ReadOnlyRecord
  # Use id as a primary key
  self.primary_key = :id

  # Each DV mapping can only belong to one {Dataset}
  belongs_to :dataset
end