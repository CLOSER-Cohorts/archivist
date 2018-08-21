# Application Controller
class ApplicationController < ActionController::Base
  include Pundit
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  include Pundit
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

  def current_user
    super || User.where(api_key: params['api_key']).where('api_key IS NOT NULL').first
  end

  def set_csrf_cookie_for_ng
    cookies['XSRF-TOKEN'] = form_authenticity_token if protect_against_forgery?
  end

  protected
  def verified_request?
    super || valid_authenticity_token?(session, request.headers['X-XSRF-TOKEN'])
  end
end
