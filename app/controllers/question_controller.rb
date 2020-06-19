class QuestionController < BasicInstrumentController
  def show
    respond_to do |f|
      f.json { render json: @object}
      f.xml  { render body: @object.to_xml_fragment, content_type: 'application/xml' }
    end
  end

  def create
    if params[:fragment_xml]
      fragment_instance = Importers::XML::DDI::FragmentInstance.new(params[:fragment_xml], @instrument)
      fragment_instance.process
      if fragment_instance.valid?
        @object = fragment_instance.questions.first
        render :show, status: :ok and return
      else
        render json: fragment_instance.errors, status: :unprocessable_entity
      end
    else
      update_question @object = collection.new(safe_params) do |obj|
        obj.save
      end
    end
  end

  def update
    update_question @object do |obj|
      obj.update(safe_params)
    end
  end

  private
  def update_question(object, &block)
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

  def collection
    @instrument.send(self.class.model_class.name.tableize).includes(rds_qs: :response_domain)
  end
end
