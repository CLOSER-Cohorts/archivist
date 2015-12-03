class ResponseDomainCodesController < ApplicationController
  before_action :set_response_domain_code, only: [:show, :edit, :update, :destroy]

  # GET /response_domain_codes
  # GET /response_domain_codes.json
  def index
    @response_domain_codes = ResponseDomainCode.all
  end

  # GET /response_domain_codes/1
  # GET /response_domain_codes/1.json
  def show
  end

  # GET /response_domain_codes/new
  def new
    @response_domain_code = ResponseDomainCode.new
  end

  # GET /response_domain_codes/1/edit
  def edit
  end

  # POST /response_domain_codes
  # POST /response_domain_codes.json
  def create
    @response_domain_code = ResponseDomainCode.new(response_domain_code_params)

    respond_to do |format|
      if @response_domain_code.save
        format.html { redirect_to @response_domain_code, notice: 'Response domain code was successfully created.' }
        format.json { render :show, status: :created, location: @response_domain_code }
      else
        format.html { render :new }
        format.json { render json: @response_domain_code.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /response_domain_codes/1
  # PATCH/PUT /response_domain_codes/1.json
  def update
    respond_to do |format|
      if @response_domain_code.update(response_domain_code_params)
        format.html { redirect_to @response_domain_code, notice: 'Response domain code was successfully updated.' }
        format.json { render :show, status: :ok, location: @response_domain_code }
      else
        format.html { render :edit }
        format.json { render json: @response_domain_code.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /response_domain_codes/1
  # DELETE /response_domain_codes/1.json
  def destroy
    @response_domain_code.destroy
    respond_to do |format|
      format.html { redirect_to response_domain_codes_url, notice: 'Response domain code was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_response_domain_code
      @response_domain_code = ResponseDomainCode.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def response_domain_code_params
      params.require(:response_domain_code).permit(:code_list_id)
    end
end
