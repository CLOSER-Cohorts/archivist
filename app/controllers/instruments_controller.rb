class InstrumentsController < ApplicationController
  include BaseController

  add_basic_actions require: ':instrument',
                    params: '[:agency, :version, :prefix, :label, :study, :files]',
                    collection: 'policy_scope(Instrument.all)',
                    only: [:copy, :response_domains, :response_domain_codes, :reorder_ccs, :stats, :export, :mapper]

  def show
    respond_to do |f|
      f.json {render json: @object}
      f.xml do
        exp = XML::DDI::Exporter.new
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
          cc = @object.send(u[:type] + 's').find(u[:id])
          parent = @object.send(u[:parent][:type] + 's').find(u[:parent][:id])
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

  def export
      Resque.enqueue ExportJob, @object.id
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
    head :ok, format: :json if files.empty?
    begin
      files.each do |file|
        doc = Document.new file: file
        doc.save!
        Resque.enqueue ImportJob, doc.id
      end
      head :ok, format: :json
    rescue  => e
      render json: {message: e}, status: :bad_request
    end
  end

  def copy
    new_details = params.select {
        |k, v| ['new_label', 'new_agency', 'new_version', 'new_study'].include? k.to_s
    }
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
end