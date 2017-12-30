class ApplicationMailer < ActionMailer::Base
  default from: (ENV["FROM_ADDRESS"] || '')
  layout 'mailer'
end
