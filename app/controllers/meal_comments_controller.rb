class MealCommentsController < ApplicationController
  before_action :require_authentication!

  def create
    meal = Meal.find(params[:meal_id])
    return unless authorize_interaction!(meal)

    meal.meal_comments.create!(user: current_user, body: comment_params[:body])
    RecommendationTracker.track_social_action!(
      user: current_user,
      event_name: "meal_commented",
      meal_name: meal.name,
      metadata: { meal_id: meal.id, owner_id: meal.user_id, occasion: meal.occasion }
    )
    redirect_back fallback_location: home_path
  rescue ActiveRecord::RecordInvalid => e
    redirect_back fallback_location: home_path, alert: e.record.errors.full_messages.to_sentence
  end

  private

  def comment_params
    params.require(:meal_comment).permit(:body)
  end

  def authorize_interaction!(meal)
    return true if meal.user == current_user || current_user.follows?(meal.user)

    redirect_back fallback_location: home_path, alert: "You cannot comment on that meal."
    false
  end
end
