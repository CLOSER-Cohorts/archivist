module Importers::Loggable
  extend ActiveSupport::Concern
  included do

    def set_import_to_running
      return unless @import
      @import.update(state: :running)
      @logs = []
      @log_entry = {}
      @errors = false
    end

    def set_import_to_finished
      return unless @import
      @import.update(state: (@errors) ? :failure : :success, log: @logs.to_json)
    end

    def log(key, value)
      return unless @import
      if key == :outcome
        @log_entry[:error] = (value =~ /Invalid/)
      end
      @log_entry[key] = value
    end

    def write_to_log
      return unless @import
      @logs << @log_entry
      @log_entry = {}
    end

  end
end
