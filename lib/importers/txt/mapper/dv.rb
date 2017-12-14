class Importers::TXT::Mapper::DV < Importers::TXT::Mapper::Dataset
  def import
    @doc.each do |v, s|
      var = @object.variables.find_by_name v
      src = @object.variables.find_by_name s
      unless var.nil? or src.nil?
        var.src_variables << src
        var.var_type = 'Derived'
        var.save!
      end
    end
  end
end