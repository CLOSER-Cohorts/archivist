class QuestionController < BasicInstrumentController
  def show
    respond_to do |f|
      f.json { render json: @object}
      f.xml  { render body: @object.to_xml_fragment, content_type: 'application/xml' }
    end
  end

  def create
    update_question @object = collection.new(safe_params) do |obj|
      obj.save
    end
  end

  def update
    update_question @object do |obj|
      obj.update(safe_params)
    end
  end

  private
  def update_question object, &block
    if block.call object
      if params.has_key? :instruction
        object.instruction = params[:instruction]
        object.save!
      end
      if params.has_key? :rds
        object.update_rds params[:rds]
        object.save!
      end
      if params.has_key? :cols
        object.update_cols params[:cols]
        object.save!
      end
      render :show, status: :ok
    else
      render json: @object.errors, status: :unprocessable_entity
    end
  end
end