class DashboardController < ApplicationController
  before_action :require_authentication!

  def show
    @dashboard = DashboardPresenter.new(user: current_user, occasion: params[:occasion])
    track_dashboard_impressions!
  end

  private

  def track_dashboard_impressions!
    session[:recommendation_impression_signatures] ||= []
    signature = @dashboard.impression_signature
    return if session[:recommendation_impression_signatures].include?(signature)

    @dashboard.track_impressions!
    session[:recommendation_impression_signatures] = (session[:recommendation_impression_signatures] + [ signature ]).last(20)
  end
end
