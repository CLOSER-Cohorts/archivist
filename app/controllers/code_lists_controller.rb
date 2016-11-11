class CodeListsController < ApplicationController
  include BaseInstrumentController

  add_basic_actions require: ':code_list',
                    params: '[:label, :codes, :min_responses, :max_responses]',
                    collection: 'Instrument.find(Prefix[params[:instrument_id]]).code_lists'

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

  # PATCH/PUT /code_lists/1.json
  def update
    parameters = safe_params

    if params.has_key? :codes
      @object.update_codes(params[:codes])
      parameters.delete :codes
    end
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
    respond_to do |format|
      if @object.update(parameters)
        format.json { render :show, status: :ok }
      else
        format.json { render json: @object.errors, status: :unprocessable_entity }
      end
    end
  end

end