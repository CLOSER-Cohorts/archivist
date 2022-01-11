class Users::RegistrationsController < Devise::RegistrationsController
  clear_respond_to
  respond_to :json
  before_action :configure_permitted_parameters, if: :devise_controller?

  # GET /resource/sign_up
  # def new
  #   super
  # end

  # POST /resource
  def create
    super do |user|
      unless user.valid?
        render(json: { errors: user.errors, error_sentence: user.errors.full_messages.to_sentence }, status: :unprocessable_entity) and return
      end
      g = UserGroup.find params[:registration][:user][:group_id]
      g.users << user
      user.editor!
      render(json: user.as_json.merge(jwt: encode_token({id: user.id, api_key: user.api_key})), status: 201) and return
    end
  end

  # GET /resource/edit
  # def edit
  #   super
  # end

  # PUT /resource
  # def update
  #   super
  # end

  # DELETE /resource
  # def destroy
  #   super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:email, :first_name, :last_name, :group_id, :role])
  end

  # The path used after sign up.
  # def after_sign_up_path_for(resource)
  #   super(resource)
  # end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end

  private

  def encode_token(payload)
    JWT.encode(payload, 's3cr3t')
  end
end
