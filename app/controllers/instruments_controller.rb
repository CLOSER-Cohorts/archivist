class InstrumentsController < BasicController
  include Importers::Controller

  has_importers({
                    mapping: ImportJob::Mapping,
                    topicq: ImportJob::TopicQ
                })
  only_set_object { %i{copy response_domains response_domain_codes reorder_ccs stats export mapper member_imports} }

  @model_class = Instrument
  @params_list = %i{agency version prefix label study files import_question_grids}

  def show
    respond_to do |f|
      f.json {render json: @object}
      f.xml do
        exp = Exporters::XML::DDI::Instrument.new
        exp.add_root_attributes
        filename = exp.run @object
        render file: filename
      end
    end
  end

  def reorder_ccs
    unless params[:updates].nil?
      params[:updates].each do |u|
        unless u[:type].nil? || u[:id].nil? || u[:parent].nil?
          cc = @object.send(u[:type].tableize).find(u[:id])
          parent = @object.send(u[:parent][:type].tableize).find(u[:parent][:id])
          unless cc.nil? or parent.nil?
            cc.position = u[:position]
            cc.parent = parent
            cc.branch = u[:branch]
            cc.cc.save!
          end
        end
      end
    end
    head :ok, format: :json
  end

  def response_domains
  end

  def response_domain_codes
  end

  def latest_document
    d = Document.where(item_id: Prefix[params[:id]], item_type: 'Instrument').order(created_at: :desc).limit(1).first
    if d.nil?
      head :ok
    else
      render body: d.file_contents, content_type: 'application/xml'
    end
  end

  def export
      Resque.enqueue ExportJob::Instrument, @object.id
      head :ok, format: :json
  end

  def mapper
    respond_to do |format|
      format.text { render 'mapper.txt.erb', layout: false, content_type: 'text/plain' }
      format.json  {}
    end
  end

  def import
    files = params[:files].nil? ? [] : params[:files]
    options = {}
    options[:question_grids] = params[:question_grids].nil? ? true : params[:question_grids]
    head :ok, format: :json if files.empty?
    begin
      files.each do |file|
        doc = Document.new file: file
        doc.save_or_get
        Resque.enqueue ImportJob::Instrument, doc.id, options
      end
      head :ok, format: :json
    rescue  => e
      render json: {message: e}, status: :bad_request
    end
  end

  def copy
    new_details = params.select {
        |k, v| %w(new_label new_agency new_version new_study).include? k.to_s
    }.map {
      |k, v| [k.gsub('new_',''), v]
    }.to_h
    new_prefix = params['new_prefix']

    begin
      Resque.enqueue CopyJob, @object.id, new_prefix, new_details
      head :ok, format: :json
    rescue => e
      render json: {message: e}, status: :internal_server_error
    end
  end

  def stats
    render json: {stats: @object.association_stats, prefix: @object.prefix}
  end

  def mapping
    respond_to do |format|
      format.text { render 'mapping.txt.erb', layout: false, content_type: 'text/plain' }
      format.json  {}
    end
  end

  private
  def set_object
    @object = collection.find(::Prefix[params[:id]])
  end
end