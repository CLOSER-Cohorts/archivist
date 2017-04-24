class QvMapping < ActiveRecord::Base
  self.primary_key = :id

  belongs_to :dataset
  belongs_to :instrument
end