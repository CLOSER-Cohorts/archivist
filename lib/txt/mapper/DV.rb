module TXT::Mapper::DV
  class Importer
    def initialize(filepath, dataset)
      @doc = File.open(filepath) { |f| TXT::TabDelimited.new(f) }
      @dataset = dataset
    end

    def import
      return if @dataset.nil?
      @doc.each do |dv_name, src_name|
        dv = @dataset.variables.find_by_name dv_name
        src = @dataset.variables.find_by_name src_name
        unless dv.nil? or src.nil?
          dv.src_variables << src
        end
      end
    end
  end
end