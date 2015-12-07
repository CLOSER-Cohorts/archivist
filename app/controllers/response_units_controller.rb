class ResponseUnitsController < ApplicationController
  before_action :set_response_unit, only: [:show, :edit, :update, :destroy]

  # GET /response_units
  # GET /response_units.json
  def index
    @response_units = ResponseUnit.all
  end

  # GET /response_units/1
  # GET /response_units/1.json
  def show
  end

  # GET /response_units/new
  def new
    @response_unit = ResponseUnit.new
  end

  # GET /response_units/1/edit
  def edit
  end

  # POST /response_units
  # POST /response_units.json
  def create
    @response_unit = ResponseUnit.new(response_unit_params)

    respond_to do |format|
      if @response_unit.save
        format.html { redirect_to @response_unit, notice: 'Response unit was successfully created.' }
        format.json { render :show, status: :created, location: @response_unit }
      else
        format.html { render :new }
        format.json { render json: @response_unit.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /response_units/1
  # PATCH/PUT /response_units/1.json
  def update
    respond_to do |format|
      if @response_unit.update(response_unit_params)
        format.html { redirect_to @response_unit, notice: 'Response unit was successfully updated.' }
        format.json { render :show, status: :ok, location: @response_unit }
      else
        format.html { render :edit }
        format.json { render json: @response_unit.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /response_units/1
  # DELETE /response_units/1.json
  def destroy
    @response_unit.destroy
    respond_to do |format|
      format.html { redirect_to response_units_url, notice: 'Response unit was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_response_unit
      @response_unit = ResponseUnit.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def response_unit_params
      params.require(:response_unit).permit(:label, :instrument_id)
    end
end
