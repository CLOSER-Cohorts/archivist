class Importers::TXT::Mapper::Mapping < Importers::TXT::Mapper::Instrument
  def initialize(thing, object)
    super
    @variables = object.datasets.map &:variables
  end

  def import
    @doc.each do |q, v|
      q_ident, q_coords = *q.split('$')
      qc = @object.cc_questions.find_by_label q_ident
      multidimensional_variable_finder = lambda do |name|
        @variables.each do |cp|
          found = cp.find_by_name name
          return found unless found.nil?
        end
        return nil
      end
      var = multidimensional_variable_finder.call(v)
      unless qc.nil? or var.nil? # qc && var
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
