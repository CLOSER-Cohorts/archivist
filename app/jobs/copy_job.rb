class CopyJob
  @queue = :in_and_out

  def self.perform (instrument_id, new_prefix, other_vals)
    begin
      orig = Instrument.find instrument_id
      orig.copy new_prefix, other_vals
    rescue => e
      Rails.logger.fatal e
    end
  end
end