class CcStatementsController < ApplicationController
  before_action :set_cc_statement, only: [:show, :edit, :update, :destroy]
  before_action :set_instrument, only: [:new, :create, :index]

  # GET /cc_statements
  # GET /cc_statements.json
  def index
    @cc_statements = @instrument.cc_statements
  end

  # GET /cc_statements/1
  # GET /cc_statements/1.json
  def show
  end

  # POST /cc_statements
  # POST /cc_statements.json
  def create
    @cc_statement = @instrument.cc_statements.new(cc_statement_params)

    respond_to do |format|
      if @cc_statement.save
        format.json { render :show, status: :created }
      else
        format.json { render json: @cc_statement.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /cc_statements/1
  # PATCH/PUT /cc_statements/1.json
  def update
    respond_to do |format|
      if @cc_statement.update(cc_statement_params)
        format.json { render :show, status: :ok }
      else
        format.json { render json: @cc_statement.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /cc_statements/1
  # DELETE /cc_statements/1.json
  def destroy
    @cc_statement.destroy
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_cc_statement
    @cc_statement = CcStatement.find(params[:id])
  end

  def set_instrument
    @instrument = Instrument.find(params[:instrument_id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def cc_statement_params
    params.require(:cc_statement).permit(:literal, :instrument_id)
  end
end
