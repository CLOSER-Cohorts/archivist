class ResponseDomainDatetimesController < ApplicationController
  before_action :set_response_domain_datetime, only: [:show, :edit, :update, :destroy]

  # GET /response_domain_datetimes
  # GET /response_domain_datetimes.json
  def index
    @response_domain_datetimes = ResponseDomainDatetime.all
  end

  # GET /response_domain_datetimes/1
  # GET /response_domain_datetimes/1.json
  def show
  end

  # GET /response_domain_datetimes/new
  def new
    @response_domain_datetime = ResponseDomainDatetime.new
  end

  # GET /response_domain_datetimes/1/edit
  def edit
  end

  # POST /response_domain_datetimes
  # POST /response_domain_datetimes.json
  def create
    @response_domain_datetime = ResponseDomainDatetime.new(response_domain_datetime_params)

    respond_to do |format|
      if @response_domain_datetime.save
        format.html { redirect_to @response_domain_datetime, notice: 'Response domain datetime was successfully created.' }
        format.json { render :show, status: :created, location: @response_domain_datetime }
      else
        format.html { render :new }
        format.json { render json: @response_domain_datetime.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /response_domain_datetimes/1
  # PATCH/PUT /response_domain_datetimes/1.json
  def update
    respond_to do |format|
      if @response_domain_datetime.update(response_domain_datetime_params)
        format.html { redirect_to @response_domain_datetime, notice: 'Response domain datetime was successfully updated.' }
        format.json { render :show, status: :ok, location: @response_domain_datetime }
      else
        format.html { render :edit }
        format.json { render json: @response_domain_datetime.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /response_domain_datetimes/1
  # DELETE /response_domain_datetimes/1.json
  def destroy
    @response_domain_datetime.destroy
    respond_to do |format|
      format.html { redirect_to response_domain_datetimes_url, notice: 'Response domain datetime was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_response_domain_datetime
      @response_domain_datetime = ResponseDomainDatetime.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def response_domain_datetime_params
      params.require(:response_domain_datetime).permit(:datetime_type, :label, :format)
    end
end
