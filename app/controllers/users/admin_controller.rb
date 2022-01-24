# frozen_string_literal: true

class Users::AdminController < ApplicationController

  def index
    @collection = User.all
  end

  def whoami
    @object = current_user
    render :show
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
    if @object.update safe_params.select {|k| %w(first_name last_name role).include?(k)}
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

  def lock
    @object = User.find safe_params['id']
    if @object.access_locked?
      @object.unlock_access!
    else
      @object.lock_access!({ send_instructions: false })
    end

    if @object.errors.empty?
      render :show, status: :ok
    else
      render json: @object.errors, status: :unprocessable_entity
    end
  end

  def destroy
    begin
      @object = User.find params['id']
      @object.destroy
      head :ok
    rescue => e
      Rails.logger.error e.message
      head :bad_request
    end
  end

  private
  def safe_params
    params.require(:admin).permit(:id, :email, :first_name, :last_name, :group_id, :role)
  end
end
