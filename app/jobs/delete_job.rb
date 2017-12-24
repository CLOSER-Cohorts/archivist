module DeleteJob; end

class DeleteJob::Instrument
  @queue = :in_and_out

  def self.perform (instrument_id)
    begin
      instrument = Instrument.find instrument_id
      instrument.destroy
    rescue => e
      Rails.logger.fatal e
    end
  end
end
