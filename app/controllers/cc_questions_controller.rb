class CcQuestionsController < ConstructController
  include Linkable::Controller

  only_set_object { %i{variables set_topic add_variables remove_variable} }

  @model_class = CcQuestion
  @params_list = [:question_id, :question_type, :response_unit_id, :topic]

  def variables
    @collection ||= @object.variables
    render 'variables/index'
  end

  def tq
    topic_mapping do |format|
      format.text { render 'tq.txt.erb', layout: false, content_type: 'text/plain' }
      format.json  { render 'tq.json.jbuilder' }
    end
  end

  def add_variables
    variable_names = params[:variable_names].is_a?(Array) ? params[:variable_names] : [params[:variable_names]]

    variables = @object.instrument.variables.where(name: variable_names)
    variables.to_a.compact!

    variables.each do |variable|
      unless @object.variables.find_by_id(variable.id)
        if params.has_key?(:x) && params.has_key?(:y)
          @object.map.create(variable: variable, x: params[:x].to_i, y: params[:y].to_i)
        else
          @object.variables << variable
        end
      end
    end
    respond_to do |format|
      format.json { render 'show' }
    end
  end

  def remove_variable
    @object.maps.where(
        variable: Variable.find(params[:variable_id]),
        x:        params[:x],
        y:        params[:y]
    ).delete_all
    respond_to do |format|
      format.json { render json: true, status: :accepted }
    end
  end
end