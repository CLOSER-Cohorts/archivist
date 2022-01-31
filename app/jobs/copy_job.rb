# frozen_string_literal: true

class CopyJob
  include Sidekiq::Worker

  sidekiq_options queue: 'in_and_out'

  def perform (instrument_id, new_prefix, other_vals)
    begin
      orig = Instrument.find instrument_id
      orig.copy new_prefix, other_vals
    rescue => e
      Rails.logger.fatal e
    end
  end
end