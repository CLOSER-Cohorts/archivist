module Importers::TXT
  class Basic
    def initialize(thing, object)
      if thing.is_a? String
        @doc = open(thing) { |f| Importers::TXT::TabDelimited.new(f) }
      else
        document = ::Document.find thing
        @doc = Importers::TXT::TabDelimited.new document.file_contents
      end
      @object = object
    end

    def cancel
    end

    def import
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
      @lines = @contents.split(/\r?\n/)

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
