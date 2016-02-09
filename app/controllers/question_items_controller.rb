class QuestionItemsController < ApplicationController
  before_action :set_question_item, only: [:show, :edit, :update, :destroy]
  before_action :set_instrument, only: [:new, :create, :index]

  # GET /question_items
  # GET /question_items.json
  def index
    @question_items = @instrument.question_items
  end

  # GET /question_items/1
  # GET /question_items/1.json
  def show
  end

  # POST /question_items
  # POST /question_items.json
  def create
    @question_item = @instrument.question_items.new(question_item_params)

    respond_to do |format|
      if @question_item.save
        format.json { render :show, status: :created }
      else
        format.json { render json: @question_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /question_items/1
  # PATCH/PUT /question_items/1.json
  def update
    respond_to do |format|
      if @question_item.update(question_item_params)
        format.json { render :show, status: :ok }
      else
        format.json { render json: @question_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /question_items/1
  # DELETE /question_items/1.json
  def destroy
    @question_item.destroy
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_question_item
      @question_item = QuestionItem.find(params[:id])
    end

    def set_instrument
      @instrument = Instrument.find(params[:instrument_id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def question_item_params
      params.require(:question_item).permit(:label, :literal, :instruction_id, :instrument_id)
    end
end
