class QuestionGridsController < ApplicationController
  before_action :set_question_grid, only: [:show, :edit, :update, :destroy]
  before_action :set_instrument, only: [:new, :create, :index]

  # GET /question_grids
  # GET /question_grids.json
  def index
    @question_grids = @instrument.question_grids
  end

  # GET /question_grids/1
  # GET /question_grids/1.json
  def show
  end

  # POST /question_grids
  # POST /question_grids.json
  def create
    @question_grid = @instrument.question_grids.new(question_grid_params)

    respond_to do |format|
      if @question_grid.save
        format.json { render :show, status: :created }
      else
        format.json { render json: @question_grid.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /question_grids/1
  # PATCH/PUT /question_grids/1.json
  def update
    respond_to do |format|
      if @question_grid.update(question_grid_params)
        format.json { render :show, status: :ok }
      else
        format.json { render json: @question_grid.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /question_grids/1
  # DELETE /question_grids/1.json
  def destroy
    @question_grid.destroy
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_question_grid
      @question_grid = QuestionGrid.find(params[:id])
    end

    def set_instrument
      @instrument = Instrument.find(params[:instrument_id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def question_grid_params
      params.require(:question_grid).permit(:label, :literal, :instruction_id, :vertical_code_list_id, :horizontal_code_list_id, :roster_rows, :roster_label, :corner_label, :instrument_id)
    end
end
