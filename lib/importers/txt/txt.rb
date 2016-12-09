module Importers::TXT
  class TabDelimited
    def initialize(file)
      @contents = file.read
    end

    def each(&block)
      @contents.split(/\r?\n/).each do |line|
        block.call(*(line.split(/\t/)))
      end
    end
  end
end