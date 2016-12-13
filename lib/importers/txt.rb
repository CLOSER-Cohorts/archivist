module Importers::TXT
  class TabDelimited
    def initialize(thing)
      if thing.is_a? String
        @contents = thing
      else
        @contents = thing.read
      end
    end

    def each(&block)
      @contents.split(/\r?\n/).each do |line|
        block.call(*(line.split(/\t/)))
      end
    end
  end
end