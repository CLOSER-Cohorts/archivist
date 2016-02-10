class VariablesController < ApplicationController
  before_action :set_variable, only: [:show, :edit, :update, :destroy]

  # GET /variables
  # GET /variables.json
  def index
    @variables = Variable.all
  end

  # GET /variables/1
  # GET /variables/1.json
  def show
  end

  # POST /variables
  # POST /variables.json
  def create
    @variable = Variable.new(variable_params)

    respond_to do |format|
      if @variable.save
        format.json { render :show, status: :created }
      else
        format.json { render json: @variable.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /variables/1
  # PATCH/PUT /variables/1.json
  def update
    respond_to do |format|
      if @variable.update(variable_params)
        format.json { render :show, status: :ok }
      else
        format.json { render json: @variable.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /variables/1
  # DELETE /variables/1.json
  def destroy
    @variable.destroy
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_variable
    @variable = Variable.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def variable_params
    params.require(:variable).permit(:name, :label, :var_type, :dataset_id)
  end
end
