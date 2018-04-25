class UserMailer < ApplicationMailer
  default from: (ENV["FROM_ADDRESS"] || '')

  def welcome(user)
    @user = user
    mail(to: @user.email, subject: 'Welcome to My Awesome Site')
  end
end
