class Importers::TXT::Mapper::DV
  def initialize(filepath, dataset)
    @doc = File.open(filepath) { |f| Importers::TXT::TabDelimited.new(f) }
    @dataset = dataset
  end

  def import
    @doc.each do |v, s|
      var = @dataset.variables.find_by_name v
      src = @dataset.variables.find_by_name s
      unless var.nil? or src.nil?
        var.src_variables << src
      end
    end
  end
end