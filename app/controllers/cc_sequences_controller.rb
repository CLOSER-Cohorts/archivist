class CcSequencesController < ApplicationController
  before_action :set_cc_sequence, only: [:show, :edit, :update, :destroy]
  before_action :set_instrument, only: [:new, :create, :index]

  # GET /cc_sequences
  # GET /cc_sequences.json
  def index
    @cc_sequences = @instrument.cc_sequences
  end

  # GET /cc_sequences/1
  # GET /cc_sequences/1.json
  def show
  end

  # POST /cc_sequences
  # POST /cc_sequences.json
  def create
    @cc_sequence = @instrument.cc_sequences.new(cc_sequence_params)

    respond_to do |format|
      if @cc_sequence.save
        format.json { render :show, status: :created }
      else
        format.json { render json: @cc_sequence.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /cc_sequences/1
  # PATCH/PUT /cc_sequences/1.json
  def update
    respond_to do |format|
      if @cc_sequence.update(cc_sequence_params)
        format.json { render :show, status: :ok }
      else
        format.json { render json: @cc_sequence.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /cc_sequences/1
  # DELETE /cc_sequences/1.json
  def destroy
    @cc_sequence.destroy
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_cc_sequence
    @cc_sequence = CcSequence.find(params[:id])
  end

  def set_instrument
    @instrument = Instrument.find(params[:instrument_id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def cc_sequence_params
    params.require(:cc_sequence).permit(:literal, :instrument_id)
  end
end
