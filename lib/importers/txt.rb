module Importers::TXT
  class Basic
    def initialize(thing, options)
      if thing.is_a? String
        @doc = open(thing) { |f| Importers::TXT::TabDelimited.new(f) }
      else
        document = ::Document.find thing
        @doc = Importers::TXT::TabDelimited.new document.file_contents
      end

      options.symbolize_keys!
      if options.has_key? :object
        if options[:object].is_a?(String) || options[:object].is_a?(Integer) || options[:object].is_a?(Symbol)
          @object = yield options[:object]
        else
          @object = options[:object]
        end
      end
      if options.has_key? :import_id
        @import = Import.find_by_id(options[:import_id])
      end
    end

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

    def cancel
    end

    def import
    end

    def object
      @object
    end
  end
  # Utility class for importing tab delimited text files
  class TabDelimited
    def initialize(thing)
      @config = {}
      if thing.is_a? String
        @contents = thing
      else
        @contents = thing.read
      end
      @lines = @contents.split(/\r\n|\r|\n/)

      while @lines.first[0] == '#'
        column, command = @lines.shift[1..-1].split(' ')
        (@config[column.to_i] ||= []) << command.to_s
      end
    end

    def config
      @config
    end

    def each(&block)
      @lines.each do |line|
        block.call(*(line.split(/\t/)))
      end
    end
  end
end
