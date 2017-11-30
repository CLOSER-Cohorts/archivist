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
      p[obj_name] = flatten_parent_param(p[obj_name])
      p[obj_name] = shim_construct_type(p[obj_name])
    end.require( obj_name )
        .permit( [:label, :parent_id, :parent_type, :position, :branch]  + self.class.params_list )
  end

  private
  def flatten_parent_param(p)
    unless p[:parent].nil?
      p[:parent_id] = p[:parent][:id]
      p[:parent_type] = p[:parent][:type]
    end
    p
  end

  def shim_construct_type(p)
    unless p[:parent_type].nil?
      p[:parent_type] = case p[:parent_type].downcase
                          when 'condition' then
                            'CcCondition'
                          when 'loop' then
                            'CcLoop'
                          when 'question' then
                            'CcQuestion'
                          when 'sequence' then
                            'CcSequence'
                          when 'statement' then
                            'CcStatement'
                        end
    end
    p
  end
end