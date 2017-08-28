class Importers::TXT::WHII::CodeList
  def initialize(thing, instrument)
    if thing.is_a? String
      @doc = open(thing) { |f| Importers::TXT::TabDelimited.new(f) }
    else
      document = ::Document.find thing
      @doc = Importers::TXT::TabDelimited.new document.file_contents
    end
    @instrument = instrument
  end

  def import
    @doc.each do |name, values|
      next if name.nil? || values.nil? || name.empty? || values.empty?

      cl = @instrument.code_lists.create label: name
      codes = values[0...-1].split ';'
      codes.each do |code|
        code_value, code_label = *code.split('= ')
        c = cl.codes.new
        c.label = code_label
        c.value = code_value
        c.save!
      end
    end
  end
end