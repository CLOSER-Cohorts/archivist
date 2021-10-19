# frozen_string_literal: true

class FallbackController < ApplicationController
  skip_before_action :authenticate_user!, :authenticate_user_from_token!, only: [:index], raise: false

  def index
    render file: 'public/index.html', layout: false
  end
end
