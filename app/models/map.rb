# A junction model to create mappings
#
# Performs either Q-V mapping for DV mapping by joining
# a {Variable} to either a {CcQuestion} or another
# Variable.
#
# === Properties
# * x
# * y
class Map < ApplicationRecord
  # Each mapping needs a source {CcQuestion} or {Variable}
  belongs_to :source, polymorphic: true
  # Every mapping has a destination {Variable}
  belongs_to :variable
end
