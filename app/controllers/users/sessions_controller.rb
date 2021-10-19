class Users::SessionsController < Devise::SessionsController
  clear_respond_to
  respond_to :json
# before_filter :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  #def new
  #  super #{UserMailer.welcome(self.resource).deliver_now}
  #end

  # POST /resource/sign_in
  def create
    self.resource = warden.authenticate!(auth_options)
    set_flash_message(:notice, :signed_in) if is_flashing_format?
    sign_in(resource_name, resource)
    respond_with(resource) do |format|
      format.json { render json: resource.as_json.merge(jwt: encode_token({id: resource.id, api_key: resource.api_key})), status: 201 }
    end
  end

  # DELETE /resource/sign_out
  #def destroy
  #  super {head :no_content and return}
  #end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.for(:sign_in) << :attribute
  # end

  private

  def encode_token(payload)
    JWT.encode(payload, 's3cr3t')
  end
end
