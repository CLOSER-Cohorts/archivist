class DatasetsController < BasicController
  include Importers::Controller

  has_importers({
                    dv: ImportJob::DV,
                    topicv: ImportJob::TopicV
                })
  only_set_object { %i{member_imports} }

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

  def latest_document
    d = Document.where(item_id: params[:id], item_type: 'Dataset').order(created_at: :desc).limit(1).first
    if d.nil?
      head :ok
    else
      render body: d.file_contents, content_type: 'application/xml'
    end
  end

  def member_imports
    imports = params[:imports].nil? ? [] : params[:imports]
    head :ok, format: :json if imports.empty?
    begin
      imports.each do |import|
        doc = Document.new file: import[:file]
        doc.save_or_get

        type = import[:type].downcase

        if type == 'dv'
          Resque.enqueue ImportJob::DV, doc.id, self
        elsif type == 'topicv'
          Resque.enqueue ImportJob::TopicV, doc.id, self
        end

      end
      head :ok, format: :json
    rescue  => e
      render json: {message: e}, status: :bad_request
    end
  end
end
