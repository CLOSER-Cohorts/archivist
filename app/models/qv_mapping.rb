class QvMapping < ActiveRecord::Base
  self.primary_key = :id

  belongs_to :instrument
  belongs_to :dataset
end