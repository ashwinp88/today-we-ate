class MealLikesController < ApplicationController
  before_action :require_authentication!
  before_action :set_meal

  def create
    current_user.meal_likes.find_or_create_by!(meal: @meal)
    RecommendationTracker.track_social_action!(
      user: current_user,
      event_name: "meal_liked",
      meal_name: @meal.name,
      metadata: { meal_id: @meal.id, owner_id: @meal.user_id }
    )
    redirect_back fallback_location: home_path
  rescue ActiveRecord::RecordInvalid => e
    redirect_back fallback_location: home_path, alert: e.record.errors.full_messages.to_sentence
  end

  def destroy
    current_user.meal_likes.find_by!(meal: @meal).destroy
    redirect_back fallback_location: home_path
  end

  private

  def set_meal
    @meal = Meal.find(params[:meal_id])
  end
end
