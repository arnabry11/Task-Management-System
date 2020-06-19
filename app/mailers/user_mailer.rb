class UserMailer < ApplicationMailer
  default from: 'Task Management System'
  def welcome_user_email(user_id)
    @user = User.find(user_id)
    @greeting = "Hi #{@user.name}"
    if Rails.env.development? || Rails.env.test?
      @url = "http://localhost:3000"
    else
      @url = "http://tms-kreeti.herokuapp.com"
    end

    mail to: @user.email, subject: "Welcome To Task Management System"
  end
end
