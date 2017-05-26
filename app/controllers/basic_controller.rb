class BasicController < ApplicationController
  @params_list = []

  class << self
    attr_accessor :model_class
    attr_accessor :params_list
  end

  def index
    @collection = collection
  end

  def show
  end

  def create
    @object = collection.new(safe_params)
    if @object.save!
      render :show, status: :created
    else
      render json: @object.errors, status: :unprocessable_entity
    end
  end

  def update
    if @object.update(safe_params)
      render :show, status: :ok
    else
      render json: @object.errors, status: :unprocessable_entity
    end
  end

  def destroy
    begin
      @object.destroy
      head :ok
    rescue => e
      logger.fatal 'Failed to destroy object'
      logger.fatal e.message
      logger.fatal e.backtrace
      render json: {message: e}, status: :bad_request
    end
  end

  protected
  def self.only_set_object
    if block_given?
      before_action :set_object, only: [:show, :update, :destroy] + yield
    else
      before_action :set_object, only: [:show, :update, :destroy]
    end
  end

  private

  def collection
    policy_scope(self.class.model_class.all)
  end

  def set_object
    Rails.logger.debug collection.inspect
    Rails.logger.debug params[:id]
    @object = collection.find(params[:id])
  end

  def self.params_list
    @params_list
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def safe_params
    params
        .require( self.class.model_class.name.underscore.to_sym )
        .permit( self.class.params_list )
  end
end