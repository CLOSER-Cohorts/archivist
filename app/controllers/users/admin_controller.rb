class Users::AdminController < ApplicationController

  def index
    @collection = User.all
  end

  def show
    @object = User.find safe_params
  end

  def create
    @object = User.new safe_params
    logger.debug @object.to_json
    if @object.save!
      render :show, status: :created
    else
      render json: user.errors, status: :unprocessable_entity
    end
  end

  def update
    @object = User.find safe_params['id']
    if @object.update safe_params.select {|k,v| %w(first_name last_name role).include?(k)}
      render :show, status: :ok
    else
      render json: user.errors, status: :unprocessable_entity
    end
  end

  def reset_password
    @object = User.find safe_params['id']
    @object.send_reset_password_instructions

    if @object.errors.empty?
      head :ok
    else
      render json: @object.errors, status: :unprocessable_entity
    end
  end

  def destroy
    begin
      @object = User.find safe_params['id']
      @object.destroy
      head :ok
    rescue
      head :bad_request
    end
  end

  private
  def safe_params
    params.require(:admin).permit(:id, :email, :first_name, :last_name, :group_id, :role)
  end
end