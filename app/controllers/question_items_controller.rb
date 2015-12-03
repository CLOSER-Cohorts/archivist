class QuestionItemsController < ApplicationController
  before_action :set_question_item, only: [:show, :edit, :update, :destroy]

  # GET /question_items
  # GET /question_items.json
  def index
    @question_items = QuestionItem.all
  end

  # GET /question_items/1
  # GET /question_items/1.json
  def show
  end

  # GET /question_items/new
  def new
    @question_item = QuestionItem.new
  end

  # GET /question_items/1/edit
  def edit
  end

  # POST /question_items
  # POST /question_items.json
  def create
    @question_item = QuestionItem.new(question_item_params)

    respond_to do |format|
      if @question_item.save
        format.html { redirect_to @question_item, notice: 'Question item was successfully created.' }
        format.json { render :show, status: :created, location: @question_item }
      else
        format.html { render :new }
        format.json { render json: @question_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /question_items/1
  # PATCH/PUT /question_items/1.json
  def update
    respond_to do |format|
      if @question_item.update(question_item_params)
        format.html { redirect_to @question_item, notice: 'Question item was successfully updated.' }
        format.json { render :show, status: :ok, location: @question_item }
      else
        format.html { render :edit }
        format.json { render json: @question_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /question_items/1
  # DELETE /question_items/1.json
  def destroy
    @question_item.destroy
    respond_to do |format|
      format.html { redirect_to question_items_url, notice: 'Question item was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_question_item
      @question_item = QuestionItem.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def question_item_params
      params.require(:question_item).permit(:label, :literal, :instruction_id)
    end
end
