class CodeListsController < BasicInstrumentController
  # Initialise finding object for item based actions
  only_set_object

  # Set model for automatic CRUD actions
  @model_class = CodeList

  # List of params that can be set and edited
  @params_list = [:label, :min_responses, :max_responses, codes_attributes: [ :id, :value, :category_id, category_attributes: [:id, :instrument_id, :label] ]]

  # POST /instruments/1/code_lists.json
  def create
    @object = collection.new(safe_params)

    if @object.save
      if params.has_key?(:rd) && params[:rd]
        @object.response_domain = true
      else
        @object.response_domain = false
      end
      render :show, status: :created
    else
      render json: { errors: @object.errors, error_sentence: @object.errors.full_messages.to_sentence }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /instruments/1/code_lists/1.json
  def update
    parameters = safe_params

    if params.has_key? :rd
      if params[:rd]
        @object.response_domain = true
        @object.response_domain.min_responses = params[:min_responses]
        @object.response_domain.max_responses = params[:max_responses]
        @object.response_domain.save!
      else
        @object.response_domain = false
      end
    end
    if @object.update_attributes(parameters)
      respond_to do |format|
        format.json { render :show, status: :ok }
      end
    else
      respond_to do |format|
        format.json { render json: { errors: @object.errors, error_sentence: @object.errors.full_messages.to_sentence }, status: :unprocessable_entity }
      end
    end
  end

  private

  def safe_params
    # The params from Angular use :codes in the params array, we
    # tranform these into params that comply with the params expected
    # by nested attributes using accepts_nested_attributes for the codes
    # and their nested categories.
    codes_params = params[:codes] ? params.delete(:codes) : params[:code_list].delete(:codes)
    if codes_params
      codes_params.map do | code |
        next if code[:value].blank? && code[:label].blank?
        existing_category = @instrument.categories.find_by_label(code[:label])
        if existing_category
          code[:category_id] = existing_category.try(:id)
        else
          code[:category_attributes] = {
            id: existing_category.try(:id) || code.delete(:category_id),
            instrument_id: @instrument.id,
            label: code.delete(:label)
          }
        end
        code
      end
      params[:code_list][:codes_attributes] = codes_params
    end
    super
  end

end
