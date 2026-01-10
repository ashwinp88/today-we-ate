class PreauthsController < ApplicationController
  def create
    email = params[:email].to_s.strip.downcase
    if email.blank?
      redirect_to root_path, alert: "Please enter your email"
      return
    end

    if (user = User.find_by(provider: "email", uid: email))
      redirect_to login_path(email: user.email)
    else
      redirect_to signup_path(email: email)
    end
  end
end

