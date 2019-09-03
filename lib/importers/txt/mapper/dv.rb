class Importers::TXT::Mapper::DV < Importers::TXT::Mapper::Dataset
  def import(options = {})
    set_import_to_running
    vars = @object.variables.includes(:questions, :src_variables, :der_variables, :topic)
    begin
        @doc.each do |v, s|
          log "#{v},#{s} - "
          var = vars.find_by_name v
          src = vars.find_by_name s
          log " matched to Variable (#{var}) AND Source (#{src})"
          unless var.nil? or src.nil?
            var.var_type = 'Derived'
            var.src_variables << src
            if var.save
              log " - Record Saved"
            else
              errors = true
              log " - Record Invalid : #{var.errors.full_messages.to_sentence}"
            end
          end
          log '\n'
        end
    rescue => exception
      Rails.logger.info exception.message
      Rails.logger.info exception.backtrace
      raise # always reraise
    end
    set_import_to_finished
  end
end
