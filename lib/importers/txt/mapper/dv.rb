class Importers::TXT::Mapper::DV < Importers::TXT::Mapper::Dataset
  def import(options = {})
    set_import_to_running
    vars = @object.variables.includes(:questions, :src_variables, :der_variables, :topic)
    begin
        @doc.each do |variable_dataset, v, source_dataset, s|
          log :input, "#{variable_dataset},#{v},#{source_dataset},#{s}"
          begin
            if variable_dataset.blank? || source_dataset.blank? || v.blank? || s.blank?
              raise StandardError.new(I18n.t('importers.txt.mapper.dv.wrong_number_of_columns', actual_number_of_columns: {a: source_dataset, b: variable_dataset, c: v, d: s}.compact.count))
            elsif variable_dataset != @object.instance_name
              raise StandardError.new(I18n.t('importers.txt.mapper.dv.record_invalid_dataset', dataset_from_line: variable_dataset, dataset_from_object: @object.instance_name))
            end
            var = vars.find_by_name v
            src = vars.find_by_name s
            log :matches, "matched to Variable (#{var}) AND Source (#{src})"
            unless var.nil? or src.nil?
              var.var_type = 'Derived'
              var.src_variables << src
              if var.save
                log :outcome, "Record Saved"
              else
                errors = true
                log :outcome, "Record Invalid : #{var.errors.full_messages.to_sentence}"
              end
            end
          rescue StandardError => e
            @errors = true
            log :outcome, (e.message =~ /Record Invalid/) ? e.message : "Record Invalid : #{e.message}"
          ensure
            write_to_log
          end
        end
    rescue => exception
      Rails.logger.info exception.message
      Rails.logger.info exception.backtrace
      raise # always reraise
    end
    set_import_to_finished
  end
end
