class CcConditionsController < ApplicationController
  before_action :set_cc_condition, only: [:show, :edit, :update, :destroy]

  # GET /cc_conditions
  # GET /cc_conditions.json
  def index
    @cc_conditions = CcCondition.all
  end

  # GET /cc_conditions/1
  # GET /cc_conditions/1.json
  def show
  end

  # GET /cc_conditions/new
  def new
    @cc_condition = CcCondition.new
  end

  # GET /cc_conditions/1/edit
  def edit
  end

  # POST /cc_conditions
  # POST /cc_conditions.json
  def create
    @cc_condition = CcCondition.new(cc_condition_params)

    respond_to do |format|
      if @cc_condition.save
        format.html { redirect_to @cc_condition, notice: 'Cc condition was successfully created.' }
        format.json { render :show, status: :created, location: @cc_condition }
      else
        format.html { render :new }
        format.json { render json: @cc_condition.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /cc_conditions/1
  # PATCH/PUT /cc_conditions/1.json
  def update
    respond_to do |format|
      if @cc_condition.update(cc_condition_params)
        format.html { redirect_to @cc_condition, notice: 'Cc condition was successfully updated.' }
        format.json { render :show, status: :ok, location: @cc_condition }
      else
        format.html { render :edit }
        format.json { render json: @cc_condition.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /cc_conditions/1
  # DELETE /cc_conditions/1.json
  def destroy
    @cc_condition.destroy
    respond_to do |format|
      format.html { redirect_to cc_conditions_url, notice: 'Cc condition was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_cc_condition
      @cc_condition = CcCondition.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def cc_condition_params
      params.require(:cc_condition).permit(:literal, :logic)
    end
end
