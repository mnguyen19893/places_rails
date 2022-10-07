class UserMailer < ApplicationMailer
  def welcome_email(user)
    @user = user
    mail(to: @user.email, subject: 'Welcome to my places')
  end

  def reset_password(user)
    @user = user
    mail(to: @user.email, subject: 'Reset password')
  end
end
