class InstrumentsController < ApplicationController
  include BaseController

  add_basic_actions require: ':instrument',
                    params: '[:agency, :version, :prefix, :label, :study, :files]',
                    collection: 'policy_scope(Instrument.all)',
                    only: [:copy, :response_domains, :response_domain_codes, :reorder_ccs, :stats]

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

  def import
    FileUtils.mkdir_p Rails.root.join('tmp', 'uploads')
    logger.debug params
    params[:files].each do |file|
      filepath = Rails.root.join(
          'tmp',
          'uploads',
          (0...8).map { (65 + rand(26)).chr }.join + '-' + file.original_filename
      )
      File.open(filepath, 'wb') do |f|
        f.write(file.read)
      end
      im = XML::CADDIES::Importer.new filepath
      im.parse
    end
    head :ok, format: :json
  end

  def copy
    @object.copy
    head :ok, format: :json
  end

  def stats
    render json: @object.association_stats
  end
end