# frozen_string_literal: true

class MainController < ApplicationController
  def index
    user_count ||= User.all.size
    user_group_count ||= UserGroup.all.size
    unless user_count == 0 && user_group_count == 0
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
        instruments: Instrument.all.size,
        questions: CcQuestion.all.size,
        variables: Variable.all.size,
        users: User.all.size
    }
    render json: counts
  end
end
