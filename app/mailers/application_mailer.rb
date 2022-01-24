# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: (ENV["FROM_ADDRESS"] || '')
  layout 'mailer'
end
