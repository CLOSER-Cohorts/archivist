module TXT::Mapper::Mapping
  class Importer
    def initialize(filepath, instrument)
      @doc = File.open(filepath) { |f| TXT::TabDelimited.new(f) }
      @instrument = instrument
      @dataset = instrument.datasets.first
    end

    def import
      @doc.each do |q, v|
        q_ident, q_coords = *q.split('$')
        qc = @instrument.cc_questions.find_by_label q_ident
        var = @dataset.variables.find_by_name v
        unless qc.nil? or var.nil?
          if q_coords.nil?
            qc.variables << var
          else
            x, y = *q_coords.split(';')
            qc.maps.create variable: var, x: x.to_i, y: y.to_i
          end
        end
      end
    end
  end
end