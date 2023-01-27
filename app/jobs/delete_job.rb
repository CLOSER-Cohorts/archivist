# frozen_string_literal: true

module DeleteJob; end

class DeleteJob::Instrument
  include Sidekiq::Worker

  sidekiq_options queue: 'in_and_out'

  def perform (instrument_id)
    begin
      instrument = ::Instrument.find instrument_id
      instrument.destroy
      ::Instrument.last.touch(:updated_at)
    rescue => e
      Rails.logger.fatal e
    end
  end
end

class DeleteJob::Dataset
  include Sidekiq::Worker

  sidekiq_options queue: 'in_and_out'

  def perform (dataset_id)
    begin
      dataset = Dataset.find dataset_id
      dataset.destroy
    rescue => e
      Rails.logger.fatal e
    end
  end
end
