class ApplicationController < ActionController::Base
  include Pundit
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  after_filter :set_csrf_cookie_for_ng

  def set_csrf_cookie_for_ng
    cookies['XSRF-TOKEN'] = form_authenticity_token if protect_against_forgery?
  end

  def index
    if User.all.count > 0 && Group.all.count > 0
      render :index
    else
      render :first
    end
  end

  def setup
    begin
      if params.has_key?('su-email') &&
          params.has_key?('su-password') &&
          params.has_key?('su-confirm') &&
          params.has_key?('su-group')

        if params['su-password'] == params['su-confirm'] && params['su-password'].length > 7
          g = Group.create label: params['su-group'], group_type: 'Centre', study: '*'
          u = User.new email: params['su-email'],
                       first_name: params['su-fname'],
                       last_name: params['su-lname']
          u.password = params['su-password']
          u.group = g
          u.save!
          u.admin!
        end

      end
    rescue
    end
    redirect_to '/'
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

  def exports

  end

  protected
  def verified_request?
    super || valid_authenticity_token?(session, request.headers['X-XSRF-TOKEN'])
  end
end
