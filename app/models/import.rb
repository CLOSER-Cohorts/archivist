# frozen_string_literal: true

class Import < ApplicationRecord
  belongs_to :document
  belongs_to :dataset
  belongs_to :instrument

  delegate :filename, to: :document, allow_nil: true

  def parsed_log
    JSON.parse(log,symbolize_names: true) rescue []
  end
end
