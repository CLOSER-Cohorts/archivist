class Importers::TXT::Mapper::Mapping < Importers::TXT::Mapper::Instrument
  def initialize(thing, options)
    super(thing, options)
    @variables = @object.datasets.map(&:variables)
  end

  def import(options = {})
    Map.where(id: @object.maps.pluck(:id)).delete_all
    set_import_to_running
    @doc.each do |q, v|
      log :input, "#{q},#{v} "
      q_ident, q_coords = *q.split('$')
      qc = @object.cc_questions.find_by_label q_ident

      multidimensional_variable_finder = lambda do |name|
        @variables.each do |cp|
          found = cp.find_by('lower(name) = ?', name.downcase)
          return found unless found.nil?
        end
        return nil
      end
      var = multidimensional_variable_finder.call(v)
      log :matches, "matched to QuestionContruct(#{qc}) AND Variable (#{var})"
      if qc.nil? || var.nil?
        @errors = true
        log :outcome, "Record Invalid as QuestionContruct and Variable where not found"
      else
        fields = { variable: var }
        unless q_coords.nil?
          x, y = *q_coords.split(';')
          fields = fields.merge(x: x.to_i, y: y.to_i)
        end
        map = qc.maps.find_or_initialize_by variable: var, x: x.to_i, y: y.to_i
        if map.save
          log :outcome, "Record Saved"
        else
          @errors = true
          log :outcome, "Record Invalid : #{map.errors.full_messages.to_sentence}"
        end
      end
      write_to_log
    end
    set_import_to_finished
  end
end
