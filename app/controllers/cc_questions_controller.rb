class CcQuestionsController < ConstructController
  include Linkable::Controller

  only_set_object { %i{variables set_topic add_variables remove_variable} }

  prepend_before_action :create_response_unit, only: [:create, :update]

  @model_class = CcQuestion
  @params_list = [:id, :question_id, :question_type, :response_unit_id, :topic]

  # If we want to create a new Response Unit then we send the new label
  # as params[:cc_question][:response_unit_id]
  def create_response_unit
    return unless params[:response_unit_id]
    return if params[:response_unit_id].is_a? Integer
    set_instrument
    params[:cc_question][:response_unit_id] = @instrument.response_units.find_or_create_by(label: params[:response_unit_id]).try(:id)
  end

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

    begin
      ActiveRecord::Base.transaction do
        variables.each do |variable|
          unless @object.variables.find_by_id(variable.id)
            if params.has_key?(:x) && params.has_key?(:y)
              @object.maps.create!(variable: variable, x: params[:x].to_i, y: params[:y].to_i, resolve_topic_conflict: true)
            else
              @object.maps.create!(variable: variable, resolve_topic_conflict: true)
            end
          end
        end
        @object.save
      end
      @object.reload
      respond_to do |format|
        format.json { render 'show' }
      end
    rescue => e
      render json: {message: e.message}, status: :conflict
    end
  end

  def remove_variable
    @object.maps.where(
        variable: Variable.find(params[:variable_id]),
        x: [params[:x], params[:x].to_i],
        y: [params[:y], params[:y].to_i],
    ).delete_all
    @object.reload
    respond_to do |format|
      format.json { render 'show' }
    end
  end

  private
  def collection
    @instrument.cc_questions.includes(:response_unit, :question, :topic, :variable_topics, link: :topic)
  end
end
