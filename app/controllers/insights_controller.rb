class InsightsController < ApplicationController
  before_action :require_authentication!

  def show
    @analytics = MealAnalytics.new(current_user)
    @top_meals = @analytics.top_meals
    @overdue_favorites = @analytics.overdue_favorites(limit: 6)
    @source_distribution = @analytics.source_distribution
    @recommendation_clicks = current_user.recommendation_events
      .where(event_name: "recommendation_click")
      .group(:source_type)
      .count
  end
end
