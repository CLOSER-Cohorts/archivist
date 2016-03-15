class InstrumentsController < ApplicationController
  before_action :set_instrument, only: [:show, :edit, :update, :destroy, :copy, :response_domains, :reorder_ccs]

  # GET /instruments
  # GET /instruments.json
  def index
    @instruments = Instrument.all
  end

  # GET /instruments/1
  # GET /instruments/1.json
  def show
  end

  def reorder_ccs
    unless params[:updates].nil?
      params[:updates].each do |u|
        cc = @instrument.send(u[:type] + 's').find(u[:id])
        parent = @instrument.send(u[:parent][:type] + 's').find(u[:parent][:id])
        unless cc.nil? or parent.nil?
          cc.position = u[:position]
          cc.parent = parent
          cc.branch = u[:branch]
          cc.cc.save!
        end
      end
    end
    head :ok, format: :json
  end

  def full
  end

  def response_domains
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
    redirect_to '/admin/import'
  end

  def copy
    @instrument.copy params[:original_id]
    head :ok, format: :json
  end

  # POST /instruments
  # POST /instruments.json
  def create
    @instrument = Instrument.new(instrument_params)

    respond_to do |format|
      if @instrument.save
        format.json { render :show, status: :created }
      else
        format.json { render json: @instrument.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /instruments/1
  # PATCH/PUT /instruments/1.json
  def update
    respond_to do |format|
      if @instrument.update(instrument_params)
        format.json { render :show, status: :ok }
      else
        format.json { render json: @instrument.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /instruments/1
  # DELETE /instruments/1.json
  def destroy
    @instrument.destroy
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_instrument
    @instrument = Instrument.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def instrument_params
    params.require(:instrument).permit(:agency, :version, :prefix, :label, :study)
  end
end
