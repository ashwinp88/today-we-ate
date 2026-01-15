class DashboardController < ApplicationController
  before_action :require_authentication!

  def show
    @meal = current_user.meals.build(ate_on: Date.current, source: :home)
    analytics = MealAnalytics.new(current_user)
    @top_meals = analytics.top_meals
    @overdue_favorites = analytics.overdue_favorites
    @source_distribution = analytics.source_distribution
    @recent_meals = current_user.meals.order(ate_on: :desc).limit(5)
  end
end
