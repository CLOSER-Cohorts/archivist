class DatasetsController < BasicController
  include Importers::Controller

  only_set_object

  has_importers({
                    dv: ImportJob::DV,
                    topicv: ImportJob::TopicV
                })

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

  # Used by importing the TXT instrument files that mapper used
  # Please note that for multiple upload to work within a nested
  # Angular 1.X form, base64 encoding was needed so we need to
  # decode the file here as well
  def member_imports
    imports = params[:imports].nil? ? [] : params[:imports]
    head :ok, format: :json if imports.empty?
    begin
      imports.each do |import|
        doc = Document.new file: Base64.decode64(import[:file])
        doc.save_or_get
        type = import[:type]&.downcase&.to_sym

        if type == :dv
          Resque.enqueue ImportJob::DV, doc.id, params[:id]
        elsif type == :topicv
          Resque.enqueue ImportJob::TopicV, doc.id, params[:id]
        end

      end
      head :ok, format: :json
    rescue  => e
      render json: {message: e}, status: :bad_request
    end
  end
end
