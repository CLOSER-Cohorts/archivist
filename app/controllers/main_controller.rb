class MainController < ApplicationController
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
          u.confirm
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
        users: User.all.count
    }
    render json: counts
  end
end
