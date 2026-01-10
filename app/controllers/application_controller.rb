class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  helper_method :current_user, :user_signed_in?
  helper_method :session_background_asset, :session_jumbotron_asset

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def user_signed_in?
    current_user.present?
  end

  def require_authentication!
    return if user_signed_in?

    redirect_to root_path, alert: "Please sign in to continue."
  end

  def session_background_asset
    session[:bg_image]
  end

  before_action :pick_background_for_session
  before_action :pick_jumbotron_for_session

  def pick_background_for_session
    return if session[:bg_image].present?

    dir_custom = Rails.root.join("app", "assets", "background")
    dir_images = Rails.root.join("app", "assets", "images", "background")
    dir_images_plural = Rails.root.join("app", "assets", "images", "backgrounds")
    dir_custom_plural = Rails.root.join("app", "assets", "backgrounds")

    candidates = []
    if Dir.exist?(dir_custom)
      Dir.children(dir_custom).each do |f|
        next unless f.match?(/\.(png|jpe?g|webp|avif|svg)\z/i)
        # In this case the directory is directly on the load path, so logical name is just the file.
        candidates << f
      end
    end

    if Dir.exist?(dir_images)
      Dir.children(dir_images).each do |f|
        next unless f.match?(/\.(png|jpe?g|webp|avif|svg)\z/i)
        # For app/assets/images/background, the logical path includes the subdirectory.
        candidates << File.join("background", f)
      end
    end

    if Dir.exist?(dir_images_plural)
      Dir.children(dir_images_plural).each do |f|
        next unless f.match?(/\.(png|jpe?g|webp|avif|svg)\z/i)
        candidates << File.join("backgrounds", f)
      end
    end

    if Dir.exist?(dir_custom_plural)
      Dir.children(dir_custom_plural).each do |f|
        next unless f.match?(/\.(png|jpe?g|webp|avif|svg)\z/i)
        candidates << f
      end
    end

    if candidates.any?
      session[:bg_image] = candidates.sample
      Rails.logger.info("[BG] Picked background for session: #{session[:bg_image]}")
    else
      Rails.logger.info("[BG] No background candidates found in: #{dir_custom}, #{dir_images}, #{dir_images_plural}, #{dir_custom_plural}")
    end
  end

  def session_jumbotron_asset
    session[:jumbo_image]
  end

  def pick_jumbotron_for_session
    landing_dir = Rails.root.join("app", "assets", "images", "landing")

    # Always prefer the landing set and reselect if not present or not a landing image
    current = session[:jumbo_image]
    if current.present?
      fs_path = Rails.root.join("app", "assets", "images", current)
      unless current.start_with?("landing/") && File.exist?(fs_path)
        session.delete(:jumbo_image)
        current = nil
      end
    end

    return if current.present?

    if Dir.exist?(landing_dir)
      files = Dir.children(landing_dir).grep(/\.(png|jpe?g|webp|avif)\z/i)
      if files.any?
        session[:jumbo_image] = File.join("landing", files.sample)
        Rails.logger.info("[HERO] Selected #{session[:jumbo_image]}")
      else
        Rails.logger.info("[HERO] No landing images found in #{landing_dir}")
      end
    else
      Rails.logger.info("[HERO] Landing images directory missing: #{landing_dir}")
    end
  end
end
