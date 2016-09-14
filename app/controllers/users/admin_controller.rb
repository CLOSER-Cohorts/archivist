class Users::AdminController < ApplicationController

  def index
    @collection = User.all
  end

  def show
    @object = User.find safe_params
  end

  def create
    @user = User.new safe_params
    logger.debug @user.to_json
    if @user.save!
      render :show, status: :created
    else
      render json: user.errors, status: :unprocessable_entity
    end
  end

  def update
    @user = User.find safe_params['id']
    if @user.update safe_params.select {|k,v| ['first_name', 'last_name', 'role'].include?(k)}
      render :show, status: :ok
    else
      render json: user.errors, status: :unprocessable_entity
    end
  end

  def destroy
    begin
      @user = User.find safe_params['id']
      @user.destroy
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