# frozen_string_literal: true

# Application Controller
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  include Pundit::Authorization
  protect_from_forgery with: :exception
  skip_before_action :verify_authenticity_token

  after_action :set_csrf_cookie_for_ng

  # around_action :collect_metrics

  # def collect_metrics
  #   start = Time.now
  #   yield
  #   duration = Time.now - start
  #   Rails.logger.info "#{controller_name}##{action_name}: #{duration}s"
  # end

  def auth_token
    full_token = request.headers['Authorization'] || params[:token]
    return unless full_token
    full_token.split(' ')[1] || full_token
  end

  def decoded_token
    if auth_token
      begin
        JWT.decode(auth_token, 's3cr3t', true, algorithm: 'HS256')
      rescue JWT::DecodeError
        nil
      end
    end
  end

  def logged_in_user
    if decoded_token
      user_id = decoded_token[0]['id']
      api_key = decoded_token[0]['api_key']
      @user = User.find_by(id: user_id, api_key: api_key)
    end
  end

  def current_user
    super || logged_in_user || User.where(api_key: params['api_key']).where('api_key IS NOT NULL').first
  end

  def set_csrf_cookie_for_ng
    cookies['XSRF-TOKEN'] = form_authenticity_token if protect_against_forgery?
  end

  protected
  def verified_request?
    super || valid_authenticity_token?(session, request.headers['X-XSRF-TOKEN'])
  end
end
