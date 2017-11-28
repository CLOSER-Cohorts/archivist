class ImportableController < BasicController
  class << self
    attr_accessor :model_importer_class
  end

  def import
    files = params[:files].nil? ? [] : params[:files]
    options = {}
    head :ok, format: :json if files.empty?
    begin
      files.each do |file|
        doc = Document.new file: file
        doc.save_or_get
        Resque.enqueue self.class.model_importer_class, doc.id, options
      end
      head :ok, format: :json
    rescue  => e
      render json: {message: e}, status: :bad_request
    end
  end
end