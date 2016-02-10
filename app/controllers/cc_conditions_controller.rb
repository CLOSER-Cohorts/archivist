class CcConditionsController < ApplicationController
  before_action :set_cc_condition, only: [:show, :edit, :update, :destroy]
  before_action :set_instrument, only: [:new, :create, :index]

  # GET /cc_conditions
  # GET /cc_conditions.json
  def index
    @cc_conditions = @instrument.cc_conditions
  end

  # GET /cc_conditions/1
  # GET /cc_conditions/1.json
  def show
  end

  # POST /cc_conditions
  # POST /cc_conditions.json
  def create
    @cc_condition = @instrument.cc_conditions.new(cc_condition_params)

    respond_to do |format|
      if @cc_condition.save
        format.json { render :show, status: :created }
      else
        format.json { render json: @cc_condition.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /cc_conditions/1
  # PATCH/PUT /cc_conditions/1.json
  def update
    respond_to do |format|
      if @cc_condition.update(cc_condition_params)
        format.json { render :show, status: :ok }
      else
        format.json { render json: @cc_condition.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /cc_conditions/1
  # DELETE /cc_conditions/1.json
  def destroy
    @cc_condition.destroy
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_cc_condition
    @cc_condition = CcCondition.find(params[:id])
  end

  def set_instrument
    @instrument = Instrument.find(params[:instrument_id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def cc_condition_params
    params.require(:cc_condition).permit(:literal, :logic, :instrument_id)
  end
end
