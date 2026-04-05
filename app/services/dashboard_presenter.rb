class DashboardPresenter
  attr_reader :user, :occasion, :meal

  def initialize(user:, occasion: nil)
    @user = user
    @occasion = normalize_occasion(occasion)
    @request = RecommendationRequest.new(user:, occasion: @occasion)
    @meal = Meal.new(user:, ate_on: Date.current, source: :home, occasion: @occasion || inferred_occasion)
    @analytics = MealAnalytics.new(user)
  end

  def personal_recommendations
    @personal_recommendations ||= PersonalRecommendationsEngine.new.call(@request)
  end

  def friend_recommendations
    @friend_recommendations ||= FriendsRecommendationsEngine.new.call(@request)
  end

  def feed_items
    @feed_items ||= FriendActivityFeed.new(user).call
  end

  def recent_meals
    @recent_meals ||= user.meals.order(ate_on: :desc).limit(6)
  end

  def top_meals
    @top_meals ||= @analytics.top_meals
  end

  def overdue_favorites
    @overdue_favorites ||= @analytics.overdue_favorites
  end


  def cold_start?
    !user.meals.exists? && user.following.none?
  end

  def selected_occasion
    occasion.presence || inferred_occasion
  end

  def selected_occasion_label
    selected_occasion.to_s.humanize.presence || "Tonight"
  end

  def fallback_recommendation
    personal_recommendations.find { |item| item[:fallback] }
  end

  def track_impressions!
    impression_recommendations.each do |recommendation|
      RecommendationTracker.track_impression(user:, recommendation:)
    end
  end

  def impression_signature
    keys = impression_recommendations.map { |item| [ item[:source_type], item[:name], item[:occasion] ].join(":") }
    [ selected_occasion, *keys ].join("|")
  end

  private

  def normalize_occasion(value)
    return value.to_s if Meal.occasions.key?(value.to_s)

    nil
  end

  def inferred_occasion
    hour = Time.zone.now.hour
    return "breakfast" if hour < 11
    return "brunch" if hour < 13
    return "lunch" if hour < 16

    "dinner"
  end

  def impression_recommendations
    @impression_recommendations ||= begin
      items = personal_recommendations.reject { |item| item[:fallback] } + friend_recommendations
      items = [ fallback_recommendation ].compact if items.empty?
      items
    end
  end
end
