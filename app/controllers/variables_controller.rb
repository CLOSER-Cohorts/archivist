class VariablesController < BasicController
  include Linkable::Controller

  prepend_before_action :set_dataset
  only_set_object { %i{set_topic add_sources remove_source} }

  @model_class = Variable
  @params_list = [:name, :label, :var_type, :dataset_id]

  def tv
    topic_mapping do |format|
      format.text { render 'tv.txt.erb', layout: false, content_type: 'text/plain' }
      format.json  { render 'tv.json.jbuilder' }
    end
  end

  def add_sources
    head :bad_request if params[:sources].nil?

    params[:sources] = JSON.parse(params[:sources]) if params[:sources].is_a?(String)

    begin
      ActiveRecord::Base.transaction do
        @object.add_sources(params[:sources][:id], params[:sources][:x], params[:sources][:y])

        if @object.errors.blank?
          @object.reload
          render 'variables/show'
        else
          render json: {message: @object.errors.full_messages}, status: :conflict
        end
      end
    rescue => e
      render json: {message: e.message}, status: :conflict
    end
  end

  def remove_source
    head :bad_request if params[:other].nil?

    params[:other] = JSON.parse(params[:other]) if params[:others].is_a?(String)



    @object.maps.where(
        source_type: params[:other][:class],
        source_id: params[:other][:id],
        x: [params[:other][:x], params[:other][:x].to_i],
        y: [params[:other][:y], params[:other][:y].to_i],
    ).delete_all
    @object.reload
    render 'variables/show'
  end

  protected
  def collection
    @dataset.variables.includes(:src_variables, :der_variables, :topic, :questions, :question_topics)
  end

  def set_dataset
    @dataset = policy_scope(Dataset).includes(variables: [:src_variables, :der_variables, :topic, :questions, :question_topics]).find(params[:dataset_id])
  end
end
