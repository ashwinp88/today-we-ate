class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  helper_method :current_user, :user_signed_in?
  helper_method :session_background_asset

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def user_signed_in?
    current_user.present?
  end

  def require_authentication!
    return if user_signed_in?

    redirect_to landing_path, alert: "Please sign in to continue."
  end

  def session_background_asset
    session[:bg_image]
  end

  before_action :pick_background_for_session

  def pick_background_for_session
    return if session[:bg_image].present?

    candidates = Rails.configuration.x.session_background_candidates || []

    if candidates.any?
      session[:bg_image] = candidates.sample
      Rails.logger.info("[BG] Picked background for session: #{session[:bg_image]}")
    else
      Rails.logger.info("[BG] No session background candidates were loaded at boot")
    end
  end

end
