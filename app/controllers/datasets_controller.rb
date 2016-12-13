class DatasetsController < BasicController
  only_set_object

  @model_class = Dataset
  @params_list = [:name]

  def index
    super
    var_counts = Variable.group(:dataset_id).count
    @collection.each { |d| d.var_count = var_counts[d.id] }
  end

  def import
    files = params[:files].nil? ? [] : params[:files]
    options = {}
    head :ok, format: :json if files.empty?
    begin
      files.each do |file|
        doc = Document.new file: file
        doc.save_or_get
        Resque.enqueue ImportJob::Dataset, doc.id, options
      end
      head :ok, format: :json
    rescue  => e
      render json: {message: e}, status: :bad_request
    end
  end
end