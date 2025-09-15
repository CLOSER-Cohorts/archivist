module Exporters::Loggable
  extend ActiveSupport::Concern
  included do

    def set_export_to_running
      return unless @export
      @export.update(state: :running)
      broadcast_progress("Export started")
      @logs = []
      @log_entry = {}
      @errors = false
    end

    def set_export_to_finished
      return unless @export
      @export.update(state: (@errors) ? :failure : :success, log: @logs.to_json)
      broadcast_progress("Export finished")
    end

    def broadcast_progress(progress)
      ActionCable.server.broadcast("exports_channel", { message: "#{progress}", timestamp: Time.current })    
    end    

    def log(key, value)
      return unless @export
      if key == :outcome
        @log_entry[:error] = (value =~ /Invalid/)
      end
      @log_entry[key] = value
    end

    def write_to_log
      return unless @export
      @logs << @log_entry
      @log_entry = {}
    end

  end
end
