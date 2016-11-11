module BaseInstrumentController
  extend ActiveSupport::Concern
  include BaseController

  included do

  end

  class_methods do
    def add_basic_actions(options = {})
      options[:params] = ((eval options[:params]).push :instrument_id).to_s

      defined?(super) && super
      before_action :set_instrument

      class_eval <<-RUBY

        private

        def set_instrument
          @instrument = policy_scope(Instrument).find(Prefix[params[:instrument_id]])
        end

      RUBY
    end
  end
end