class RecommendationSelectionsController < ApplicationController
  before_action :require_authentication!

  def create
    recommendation = {
      name: params[:name].presence || params.require(:meal_name),
      source_type: params.require(:source_type),
      occasion: params[:occasion].presence
    }

    RecommendationTracker.track_click(user: current_user, recommendation:, metadata: { redirect_target: new_meal_path })

    redirect_to new_meal_path(meal: { name: recommendation[:name], occasion: recommendation[:occasion] })
  end
end
