class CodeListsController < BasicInstrumentController
  # Initialise finding object for item based actions
  only_set_object

  # Set model for automatic CRUD actions
  @model_class = CodeList

  # List of params that can be set and edited
  @params_list = [:label, :min_responses, :max_responses, codes_attributes: [ :id, :value, category_attributes: [:id, :label] ]]

  rescue_from ActiveRecord::RecordInvalid do |e|
    render json: e.record.errors.full_messages, status: :unprocessable_entity
  end

  # POST /instruments/1/code_lists.json
  def create
    @object = collection.new(safe_params)

    if @object.save
      if params.has_key? :codes
        @object.update_codes(params[:codes])
      end
      if params.has_key?(:rd) && params[:rd]
        @object.response_domain = true
      else
        @object.response_domain = false
      end
      render :show, status: :created
    else
      render json: @object.errors, status: :unprocessable_entity
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
        format.json { render json: @object.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def safe_params
    # The params from Angular use :codes in the params array, we
    # tranform these into params that comply with the params expected
    # by nested attributes using accepts_nested_attributes for the codes
    # and their nested categories.
    codes_params = params[:code_list].delete(:codes)
    if codes_params
      codes_params.map do | code |
        code[:category_attributes] = {
          id: code.delete(:category_id),
          label: code.delete(:label)
        }
        code
      end
      params[:code_list][:codes_attributes] = codes_params
    end
    super
  end

end
