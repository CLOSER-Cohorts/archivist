class MainController < ApplicationController
  def index
    if User.all.count > 0 && UserGroup.all.count > 0
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

        User.setup_initial_superuser params
      end
    rescue
      Rails.logger.error 'Could not create the initial superadmin.'
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
