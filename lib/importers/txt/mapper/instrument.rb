class Importers::TXT::Mapper::Instrument < Importers::TXT::Basic
  def initialize(thing, options)
    super(thing, options) do |instrument_id|
      Instrument.find instrument_id
    end
  end
end