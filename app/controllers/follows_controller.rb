class FollowsController < ApplicationController
  before_action :require_authentication!

  def create
    followed = User.find(params[:followed_id] || params[:user_id])
    follow = current_user.active_follows.find_or_initialize_by(followed: followed)

    if follow.save
      redirect_back fallback_location: people_path, notice: "Now following #{follow.followed.first_name}."
    else
      redirect_back fallback_location: people_path, alert: follow.errors.full_messages.to_sentence
    end
  end

  def destroy
    follow = current_user.active_follows.find_by!(followed_id: params[:user_id])
    name = follow.followed.first_name
    follow.destroy
    redirect_back fallback_location: people_path, notice: "Stopped following #{name}."
  end
end
