class Import < ApplicationRecord
  belongs_to :document
  belongs_to :dataset

  delegate :filename, to: :document, allow_nil: true
end
