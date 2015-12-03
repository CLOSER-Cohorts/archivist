class CcSequencesController < ApplicationController
  before_action :set_cc_sequence, only: [:show, :edit, :update, :destroy]

  # GET /cc_sequences
  # GET /cc_sequences.json
  def index
    @cc_sequences = CcSequence.all
  end

  # GET /cc_sequences/1
  # GET /cc_sequences/1.json
  def show
  end

  # GET /cc_sequences/new
  def new
    @cc_sequence = CcSequence.new
  end

  # GET /cc_sequences/1/edit
  def edit
  end

  # POST /cc_sequences
  # POST /cc_sequences.json
  def create
    @cc_sequence = CcSequence.new(cc_sequence_params)

    respond_to do |format|
      if @cc_sequence.save
        format.html { redirect_to @cc_sequence, notice: 'Cc sequence was successfully created.' }
        format.json { render :show, status: :created, location: @cc_sequence }
      else
        format.html { render :new }
        format.json { render json: @cc_sequence.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /cc_sequences/1
  # PATCH/PUT /cc_sequences/1.json
  def update
    respond_to do |format|
      if @cc_sequence.update(cc_sequence_params)
        format.html { redirect_to @cc_sequence, notice: 'Cc sequence was successfully updated.' }
        format.json { render :show, status: :ok, location: @cc_sequence }
      else
        format.html { render :edit }
        format.json { render json: @cc_sequence.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /cc_sequences/1
  # DELETE /cc_sequences/1.json
  def destroy
    @cc_sequence.destroy
    respond_to do |format|
      format.html { redirect_to cc_sequences_url, notice: 'Cc sequence was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_cc_sequence
      @cc_sequence = CcSequence.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def cc_sequence_params
      params.require(:cc_sequence).permit(:literal)
    end
end
