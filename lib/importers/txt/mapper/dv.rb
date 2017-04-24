class Importers::TXT::Mapper::DV
  def initialize(thing, dataset)
    if thing.is_a? String
      @doc = open(thing) { |f| Importers::TXT::TabDelimited.new(f) }
    else
      document = ::Document.find thing
      @doc = Importers::TXT::TabDelimited.new document.file_contents
    end
    @dataset = dataset
  end

  def import
    @doc.each do |v, s|
      var = @dataset.variables.find_by_name v
      src = @dataset.variables.find_by_name s
      unless var.nil? or src.nil?
        var.src_variables << src
        var.var_type = 'Derived'
        var.save!
      end
    end
  end
end