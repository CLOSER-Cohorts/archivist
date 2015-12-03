class ResponseDomainTextsController < ApplicationController
  before_action :set_response_domain_text, only: [:show, :edit, :update, :destroy]

  # GET /response_domain_texts
  # GET /response_domain_texts.json
  def index
    @response_domain_texts = ResponseDomainText.all
  end

  # GET /response_domain_texts/1
  # GET /response_domain_texts/1.json
  def show
  end

  # GET /response_domain_texts/new
  def new
    @response_domain_text = ResponseDomainText.new
  end

  # GET /response_domain_texts/1/edit
  def edit
  end

  # POST /response_domain_texts
  # POST /response_domain_texts.json
  def create
    @response_domain_text = ResponseDomainText.new(response_domain_text_params)

    respond_to do |format|
      if @response_domain_text.save
        format.html { redirect_to @response_domain_text, notice: 'Response domain text was successfully created.' }
        format.json { render :show, status: :created, location: @response_domain_text }
      else
        format.html { render :new }
        format.json { render json: @response_domain_text.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /response_domain_texts/1
  # PATCH/PUT /response_domain_texts/1.json
  def update
    respond_to do |format|
      if @response_domain_text.update(response_domain_text_params)
        format.html { redirect_to @response_domain_text, notice: 'Response domain text was successfully updated.' }
        format.json { render :show, status: :ok, location: @response_domain_text }
      else
        format.html { render :edit }
        format.json { render json: @response_domain_text.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /response_domain_texts/1
  # DELETE /response_domain_texts/1.json
  def destroy
    @response_domain_text.destroy
    respond_to do |format|
      format.html { redirect_to response_domain_texts_url, notice: 'Response domain text was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_response_domain_text
      @response_domain_text = ResponseDomainText.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def response_domain_text_params
      params.require(:response_domain_text).permit(:label, :maxlen)
    end
end
