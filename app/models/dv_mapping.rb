class DvMapping < ActiveRecord::Base
  self.primary_key = :id

  belongs_to :dataset
end