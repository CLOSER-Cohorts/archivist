class UserMailer < ApplicationMailer
  default from: 'w.poynter@ucl.ac.uk'

  def welcome(user)
    @user = user
    mail(to: @user.email, subject: 'Welcome to My Awesome Site')
  end
end
