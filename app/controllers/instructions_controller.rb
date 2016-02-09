class InstructionsController < ApplicationController
  before_action :set_instruction, only: [:show, :edit, :update, :destroy]
  before_action :set_instrument, only: [:index, :new, :create]

  # GET /instructions
  # GET /instructions.json
  def index
    @instructions = @instrument.instructions
  end

  # GET /instructions/1
  # GET /instructions/1.json
  def show
  end

  # POST /instructions
  # POST /instructions.json
  def create
    @instruction = @instrument.instructions.new(instruction_params)

    respond_to do |format|
      if @instruction.save
        format.json { render :show, status: :created  }
      else
        format.json { render json: @instruction.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /instructions/1
  # PATCH/PUT /instructions/1.json
  def update
    respond_to do |format|
      if @instruction.update(instruction_params)
        format.json { render :show, status: :ok }
      else
        format.json { render json: @instruction.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /instructions/1
  # DELETE /instructions/1.json
  def destroy
    @instruction.destroy
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_instruction
      @instruction = Instruction.find(params[:id])
    end

    def set_instrument
      @instrument = Instrument.find(params[:instrument_id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def instruction_params
      params.require(:instruction).permit(:text, :instrument_id)
    end
end
