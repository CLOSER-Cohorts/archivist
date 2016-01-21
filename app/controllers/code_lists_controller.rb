class CodeListsController < ApplicationController
  before_action :set_code_list, only: [:show, :edit, :update, :destroy]
  before_action :set_instrument, only: [:index, :new, :create]

  # GET /code_lists
  # GET /code_lists.json
  def index
    @code_lists = @instrument.code_lists
  end

  # GET /code_lists/1
  # GET /code_lists/1.json
  def show
  end

  # GET /code_lists/new
  def new
    @code_list = @instrument.code_lists.new
  end

  # GET /code_lists/1/edit
  def edit
  end

  # POST /code_lists
  # POST /code_lists.json
  def create
    @code_list = @instrument.code_lists.new(code_list_params)

    respond_to do |format|
      if @code_list.save
        format.html { redirect_to @code_list, notice: 'Code list was successfully created.' }
        format.json { render :show, status: :created, location: @code_list }
      else
        format.html { render :new }
        format.json { render json: @code_list.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /code_lists/1
  # PATCH/PUT /code_lists/1.json
  def update
    parameters = code_list_params

    if params.has_key? :codes
      @code_list.update_codes(params[:codes])
      parameters.delete :codes
    end
    respond_to do |format|
      if @code_list.update(parameters)
        format.html { redirect_to @code_list, notice: 'Code list was successfully updated.' }
        format.json { render :show, status: :ok}
      else
        format.html { render :edit }
        format.json { render json: @code_list.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /code_lists/1
  # DELETE /code_lists/1.json
  def destroy
    @code_list.destroy
    respond_to do |format|
      format.html { redirect_to code_lists_url, notice: 'Code list was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_code_list
      @code_list = CodeList.find(params[:id])
    end

    def set_instrument
      @instrument = Instrument.find(params[:instrument_id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def code_list_params
      params.require(:code_list).permit(:label, :instrument_id, :codes)
    end
end
