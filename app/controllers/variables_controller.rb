class VariablesController < BasicController
  prepend_before_action :set_dataset
  only_set_object { %i{set_topic add_sources remove_source} }

  @model_class = Variable
  @params_list = [:name, :label, :var_type, :dataset_id]

  def tv
    @collection = collection.order(:id)
    @collection.each { |v| v.strand }
    respond_to do |format|
      format.text { render 'tv.txt.erb', layout: false, content_type: 'text/plain' }
      format.json  {}
    end
  end

  def set_topic
    topic = Topic.find_by_id params[:topic_id]

    begin
      @object.topic = topic
      @object.save!

      head :ok
    rescue Exceptions::TopicConflictError
      render json: {message: 'Could not set topic as it would cause a conflict.'}, status: :conflict
    rescue => e
      render json: e, status: :bad_request
    end
  end

  def add_sources
    head :bad_request if params[:sources].nil?

    params[:sources] = JSON.parse(params[:sources])

    @object.add_sources(params[:sources][:id], params[:sources][:x], params[:sources][:y])

    render 'variables/show'
  end

  def remove_source
    head :bad_request if params[:other].nil?

    params[:other] = JSON.parse(params[:other])
    @object.maps.where(
        source_type: params[:other][:class],
        source_id: params[:other][:id],
        x: params[:other][:x],
        y: params[:other][:y]
    ).delete_all

    render 'variables/show'
  end

  protected
  def collection
    @dataset.variables
  end

  def set_dataset
    @dataset = policy_scope(Dataset).includes(variables: [:questions, :src_variables, :der_variables, :topic] ).find(params[:dataset_id])
  end
end