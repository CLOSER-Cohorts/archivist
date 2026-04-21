class Importers::TXT::Mapper::Mapping < Importers::TXT::Mapper::Instrument
  def initialize(thing, options)
    super(thing, options)
    @variables_hash = @object.datasets.each_with_object({}) do |dataset, hash|
      hash[dataset.instance_name] = dataset.variables
    end
  end

  def import(options = {})
    Map.where(id: @object.maps.pluck(:id)).delete_all
    set_import_to_running
    @datasets_touched = []

    @doc.each do |control_construct_scheme, q, dataset, v|
      @datasets_touched << dataset if dataset.present?
      log :input, "#{control_construct_scheme},#{q},#{dataset},#{v}"
      begin
        if control_construct_scheme.blank? || dataset.blank? || q.blank? || v.blank?
          raise StandardError.new(I18n.t('importers.txt.mapper.mapping.wrong_number_of_columns', actual_number_of_columns: {a: control_construct_scheme, b: q, c: v, d: dataset}.compact_blank.count))
        elsif control_construct_scheme != @object.control_construct_scheme
          raise StandardError.new(I18n.t('importers.txt.mapper.mapping.record_invalid_control_construct_scheme', control_construct_scheme_from_line: control_construct_scheme, control_construct_scheme_from_object: @object.control_construct_scheme))
        end

        q_ident, q_coords = *q.split('$')
        qc = @object.cc_questions.find_by_label q_ident

        unless @variables_hash.keys.include?(dataset)
          raise StandardError.new(I18n.t('importers.txt.mapper.mapping.dataset_not_associated_to_instrument', dataset: dataset))
        end

        multidimensional_variable_finder = lambda do |name|
          return unless name
          found = @variables_hash[dataset].find_by('lower(name) = ?', name.downcase)
          return found unless found.nil?
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
      rescue StandardError => e
        @errors = true
        log :outcome, (e.message =~ /Record Invalid/) ? e.message : "Record Invalid : #{e.message}"
      ensure
        write_to_log
      end
    end

    check_completeness
    set_import_to_finished
  end

  private

  def check_completeness
    return unless @import

    unique_datasets = @datasets_touched.uniq.compact
    all_instrument_datasets = @object.datasets.to_a
    referenced_datasets = if unique_datasets.empty?
      all_instrument_datasets
    else
      all_instrument_datasets.select { |ds| unique_datasets.include?(ds.instance_name) }
    end

    return if referenced_datasets.empty?

    dataset_ids = referenced_datasets.map(&:id)
    dataset_names = referenced_datasets.map(&:instance_name).to_sentence

    @object.cc_questions.each do |cc_question|
      next if cc_question.maps.joins(:variable).where(variables: { dataset_id: dataset_ids }).exists?

      @errors = true
      log :input, "#{@object.control_construct_scheme},#{cc_question.label},?,?"
      log :outcome, I18n.t('importers.txt.mapper.mapping.question_not_mapped',
                           question_label: cc_question.label,
                           datasets: dataset_names)
      write_to_log
    end
  end
end
