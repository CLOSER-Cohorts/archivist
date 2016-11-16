class BasicInstrumentController < BasicController
  prepend_before_action :set_instrument

  private
  def collection
    @instrument.send self.class.model_class.name.tableize
  end

  def set_instrument
    @instrument = policy_scope(Instrument).find(::Prefix[params[:instrument_id]])
  end

  def self.params_list
    param_list = defined?(super) ? super : []
    param_list + ['instrument_id']
  end
end