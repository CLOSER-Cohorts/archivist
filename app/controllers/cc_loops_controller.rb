class CcLoopsController < ApplicationController
  before_action :set_cc_loop, only: [:show, :edit, :update, :destroy]
  before_action :set_instrument, only: [:new, :create, :index]

  # GET /cc_loops
  # GET /cc_loops.json
  def index
    @cc_loops = @instrument.cc_loops
  end

  # GET /cc_loops/1
  # GET /cc_loops/1.json
  def show
  end

  # POST /cc_loops
  # POST /cc_loops.json
  def create
    @cc_loop = @instrument.cc_loops.new(cc_loop_params)

    respond_to do |format|
      if @cc_loop.save
        format.json { render :show, status: :created }
      else
        format.json { render json: @cc_loop.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /cc_loops/1
  # PATCH/PUT /cc_loops/1.json
  def update
    respond_to do |format|
      if @cc_loop.update(cc_loop_params)
        format.json { render :show, status: :ok }
      else
        format.json { render json: @cc_loop.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /cc_loops/1
  # DELETE /cc_loops/1.json
  def destroy
    @cc_loop.destroy
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_cc_loop
    @cc_loop = CcLoop.find(params[:id])
  end

  def set_instrument
    @instrument = Instrument.find(params[:instrument_id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def cc_loop_params
    params.require(:cc_loop).permit(:loop_var, :start_val, :end_val, :loop_while, :instrument_id)
  end
end
