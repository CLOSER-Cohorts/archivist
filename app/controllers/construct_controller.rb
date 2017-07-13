class ConstructController < BasicInstrumentController
  def create
    @object = collection.create(safe_params)
    if @object
      render :show, status: :created
    else
      render json: @object.errors, status: :unprocessable_entity
    end
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def safe_params
    obj_name = self.class.model_class.name.underscore.to_sym
    params.tap do |p|
      unless p[obj_name][:parent].nil?
        p[obj_name][:parent_id] = p[obj_name][:parent][:id]
        p[obj_name][:parent_type] = p[obj_name][:parent][:type]
      end
      unless p[obj_name][:parent_type].nil?
        p[obj_name][:parent_type] = case p[obj_name][:parent_type].downcase
                                      when 'condition' then 'CcCondition'
                                      when 'loop' then 'CcLoop'
                                      when 'question' then 'CcQuestion'
                                      when 'sequence' then 'CcSequence'
                                      when 'statement' then 'CcStatement'
                                    end
      end
    end.require( obj_name )
        .permit( [:label, :parent_id, :parent_type, :position, :branch]  + self.class.params_list )
  end
end