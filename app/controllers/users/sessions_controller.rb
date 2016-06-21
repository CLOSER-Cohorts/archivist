class Users::SessionsController < Devise::SessionsController
  clear_respond_to
  respond_to :json
# before_filter :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  #def new
  #  super #{UserMailer.welcome(self.resource).deliver_now}
  #end

  # POST /resource/sign_in
  #def create
  #  super #{UserMailer.welcome(self.resource).deliver_now}
  #end

  # DELETE /resource/sign_out
  #def destroy
  #  super {head :no_content and return}
  #end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.for(:sign_in) << :attribute
  # end
end
