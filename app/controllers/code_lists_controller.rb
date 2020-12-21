class CodeListsController < BasicInstrumentController
  # Initialise finding object for item based actions
  only_set_object

  # Set model for automatic CRUD actions
  @model_class = CodeList

  # List of params that can be set and edited
  @params_list = [:label, response_domain_code_attributes: [:id, :min_responses, :max_responses, :instrument_id, :_destroy], codes_attributes: [ :id, :value, :order, :_destroy, :category_id, category_attributes: [:id, :instrument_id, :label] ]]

  # POST /instruments/1/code_lists.json
  def create
    @object = collection.new(safe_params)

    if @object.save
      render :show, status: :created
    else
      render json: { errors: @object.errors, error_sentence: @object.errors.full_messages.to_sentence }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /instruments/1/code_lists/1.json
  def update
    parameters = safe_params
    if @object.update_attributes(parameters)
      # We need to reload otherwise the response_domain association will
      # be returned in the JSON even after it has been removed.
      @object.reload
      respond_to do |format|
        format.json { render :show, status: :ok }
      end
    else
      respond_to do |format|
        errors = @object.errors.keys.map do |attribute|
          attr_name = attribute.to_s.split('.').last.tr(".", "_").humanize
          attr_name = @object.class.human_attribute_name(attribute, default: attr_name)
          "#{attr_name} #{@object.errors[attribute].to_sentence}. "
        end
        Rails.logger.info "@object.errors - #{errors.inspect}"
        format.json { render json: { errors: @object.errors, error_sentence: errors.join }, status: :unprocessable_entity }
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
      codes_params.map.with_index do | code, index |
        code[:order] = index + 1 unless code[:order].present?
        next if code[:value].blank? && code[:label].blank?
        existing_category = @instrument.categories.find_by_label(code[:label])

        if existing_category
          code[:category_id] = existing_category.try(:id)
        else
          category_attributes = {
            instrument_id: @instrument.id,
            label: code.delete(:label)
          }
          existing_category_from_id = @instrument.categories.find_by_id(code[:category_id])
          if existing_category_from_id && (existing_category_from_id.codes.map(&:id) == [code[:id].to_i] || existing_category_from_id.codes.empty?)
            category_attributes[:id] = code.delete(:category_id)
          end
          code[:category_attributes] = category_attributes
        end
        code
      end

      # We delete any codes which weren't part of the code_params
      if @object && @object.codes
        existing_codes_id = @object.codes.pluck(:id).map(&:to_i)
        new_code_ids = codes_params.map{|code| code[:id].to_i}
        (existing_codes_id - new_code_ids).each do | code_id |
          codes_params << {
            id: code_id,
            _destroy: true
          }
        end
      end
      params[:code_list][:codes_attributes] = codes_params
    end

    response_domain_code = (@object) ? @object.response_domain_code : nil
    if params.has_key?(:rd) && params[:rd]
      params[:code_list][:response_domain_code_attributes] = { id: response_domain_code.try(:id), min_responses: params[:min_responses] || 1, max_responses: params[:max_responses] || 1 }
    else
      params[:code_list][:response_domain_code_attributes] = { id: response_domain_code.try(:id), _destroy: true }
    end
    super
  end

  def collection
    @instrument.code_lists.includes(:codes, :qgrids_via_h, :qgrids_via_v, response_domain_code: [:question_items, :question_grids])
  end

end
