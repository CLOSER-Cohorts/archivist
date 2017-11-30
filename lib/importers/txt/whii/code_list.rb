class Importers::TXT::WHII::CodeList < Importers::TXT::Basic
  def import
    @doc.each do |name, values|
      next if name.nil? || values.nil? || name.empty? || values.empty?

      cl = @object.code_lists.create label: name
      codes = values[0...-1].split ';'
      codes.each do |code|
        code_value, code_label = *code.split('= ')
        c = cl.codes.new
        c.label = code_label
        c.value = code_value
        c.save!
      end
    end
  end
end