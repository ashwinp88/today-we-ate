class SessionsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :create

  def new
  end

  def email
    email = params[:email].to_s.downcase
    user = User.find_by(provider: "email", uid: email)
    if user&.authenticate(params[:password])
      reset_session
      session[:user_id] = user.id
      redirect_to root_path, notice: "Welcome back, #{user.first_name}!"
    else
      flash.now[:alert] = "Invalid email or password"
      render :new, status: :unprocessable_entity
    end
  end

  def create
    auth_hash = request.env["omniauth.auth"]
    if auth_hash.blank?
      redirect_to root_path, alert: "Missing authentication data."
      return
    end

    user = User.from_omniauth(auth_hash)
    reset_session
    session[:user_id] = user.id

    redirect_to root_path, notice: "Welcome back, #{user.first_name}!"
  rescue StandardError => e
    Rails.logger.error("Authentication failure: #{e.message}")
    redirect_to root_path, alert: "We couldn't sign you in. Please try again."
  end

  def destroy
    reset_session
    redirect_to root_path, notice: "Signed out successfully."
  end

  def failure
    redirect_to root_path, alert: params[:message] || "Login failed."
  end
end
