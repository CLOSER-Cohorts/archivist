# frozen_string_literal: true

# An abstract controller to handle the basic CRUD
# operations
class BasicController < ApplicationController
  # List of params that can be set and edited
  @params_list = []

  # Defines class methods
  class << self
    # Makes model_class set and get-able
    attr_accessor :model_class

    # Makes params_list set and get-able
    attr_accessor :params_list
  end

  # Index action is used to generate a list of items, often scoped
  def index
    @collection = collection
    respond_to do |format|
      format.text { render 'index.txt.erb', layout: false, content_type: 'text/plain' }
      format.json
    end
  end

  # Show action is used to provide greater detail of a single item
  def show
  end

  # Create action is used to create new items
  def create
    @object = collection.new(safe_params)
    if @object.save!
      render :show, status: :created
    else
      render json: @object.errors.full_messages.to_sentence, status: :unprocessable_entity
    end
  end

  # Update action is used to make edits to an existing item
  def update
    if @object.update(safe_params)
      render :show, status: :ok
    else
      render json: @object.errors.full_messages.to_sentence, status: :unprocessable_entity
    end
  end

  # Destroy action is used to delete an existing item
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

  protected # Protected methods

  # Sets the object for the provided actions
  #
  # The object should be set for all actions that focus on a single
  # e.g. edit or delete
  def self.only_set_object
    if block_given?
      before_action :set_object, only: [:show, :update, :destroy] + yield
    else
      before_action :set_object, only: [:show, :update, :destroy]
    end
  end

  private # Private methods

  # Returns the scoped collection
  #
  # @return [ActiveRecord::Associations::CollectionProxy] Scoped collection
  def collection
    policy_scope(self.class.model_class.all)
  end

  # Finds object from collection using id
  #
  # @return [ApplicationRecord] Found object
  def set_object
    @object = collection.find(params[:id])
  end

  # Returns white listed parameters' keys
  #
  # @return [Array] White listed parameters' keys
  def self.params_list
    @params_list
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  #
  # @return [Array] White listed parameters
  def safe_params
    params
    .require( self.class.model_class.name.underscore.to_sym )
    .permit( self.class.params_list )
  end
end
