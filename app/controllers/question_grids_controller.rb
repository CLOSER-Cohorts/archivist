class QuestionGridsController < ApplicationController
  before_action :set_question_grid, only: [:show, :edit, :update, :destroy]

  # GET /question_grids
  # GET /question_grids.json
  def index
    @question_grids = QuestionGrid.all
  end

  # GET /question_grids/1
  # GET /question_grids/1.json
  def show
  end

  # GET /question_grids/new
  def new
    @question_grid = QuestionGrid.new
  end

  # GET /question_grids/1/edit
  def edit
  end

  # POST /question_grids
  # POST /question_grids.json
  def create
    @question_grid = QuestionGrid.new(question_grid_params)

    respond_to do |format|
      if @question_grid.save
        format.html { redirect_to @question_grid, notice: 'Question grid was successfully created.' }
        format.json { render :show, status: :created, location: @question_grid }
      else
        format.html { render :new }
        format.json { render json: @question_grid.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /question_grids/1
  # PATCH/PUT /question_grids/1.json
  def update
    respond_to do |format|
      if @question_grid.update(question_grid_params)
        format.html { redirect_to @question_grid, notice: 'Question grid was successfully updated.' }
        format.json { render :show, status: :ok, location: @question_grid }
      else
        format.html { render :edit }
        format.json { render json: @question_grid.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /question_grids/1
  # DELETE /question_grids/1.json
  def destroy
    @question_grid.destroy
    respond_to do |format|
      format.html { redirect_to question_grids_url, notice: 'Question grid was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_question_grid
      @question_grid = QuestionGrid.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def question_grid_params
      params.require(:question_grid).permit(:label, :literal, :instruction_id, :vertical_code_list_id, :horizontal_code_list_id, :roster_rows, :roster_label, :corner_label, :instrument_id)
    end
end
