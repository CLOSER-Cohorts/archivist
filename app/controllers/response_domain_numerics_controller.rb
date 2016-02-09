class ResponseDomainNumericsController < ApplicationController
  before_action :set_response_domain_numeric, only: [:show, :edit, :update, :destroy]

  # GET /response_domain_numerics
  # GET /response_domain_numerics.json
  def index
    @response_domain_numerics = ResponseDomainNumeric.all
  end

  # GET /response_domain_numerics/1
  # GET /response_domain_numerics/1.json
  def show
  end

  # POST /response_domain_numerics
  # POST /response_domain_numerics.json
  def create
    @response_domain_numeric = ResponseDomainNumeric.new(response_domain_numeric_params)

    respond_to do |format|
      if @response_domain_numeric.save
        format.json { render :show, status: :created }
      else
        format.json { render json: @response_domain_numeric.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /response_domain_numerics/1
  # PATCH/PUT /response_domain_numerics/1.json
  def update
    respond_to do |format|
      if @response_domain_numeric.update(response_domain_numeric_params)
        format.json { render :show, status: :ok }
      else
        format.json { render json: @response_domain_numeric.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /response_domain_numerics/1
  # DELETE /response_domain_numerics/1.json
  def destroy
    @response_domain_numeric.destroy
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_response_domain_numeric
      @response_domain_numeric = ResponseDomainNumeric.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def response_domain_numeric_params
      params.require(:response_domain_numeric).permit(:numeric_type, :label, :min, :max, :instrument_id)
    end
end
