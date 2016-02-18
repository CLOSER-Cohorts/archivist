class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  after_filter :set_csrf_cookie_for_ng

  def set_csrf_cookie_for_ng
    cookies['XSRF-TOKEN'] = form_authenticity_token if protect_against_forgery?
  end

  def index
  end

  def studies
    studies = ActiveRecord::Base.connection.execute('SELECT study, COUNT(*) FROM instruments GROUP BY study')
    render json: studies
  end

  def stats
    counts = {
        instruments: Instrument.all.count,
        questions: CcQuestion.all.count,
        variables: Variable.all.count,
        users: 0
    }
    render json: counts
  end

  protected
  def verified_request?
    super || valid_authenticity_token?(session, request.headers['X-XSRF-TOKEN'])
  end
end
