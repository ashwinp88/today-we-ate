class FriendsRecommendationsEngine
  def call(request)
    recommendations = []
    followed_ids = request.user.following.select(:id)

    if followed_ids.exists?
      following_scope = scoped_meals(Meal.where(user_id: followed_ids), request)
      recommendations.concat(grouped_recommendations(following_scope, limit: 1, source_type: "following"))
    end

    remaining = request.limit - recommendations.length
    return recommendations if remaining <= 0

    popular_scope = scoped_meals(Meal.where.not(user_id: request.user.id), request)
    popular = grouped_recommendations(popular_scope, limit: remaining + recommendations.length, source_type: "popular")
      .reject { |item| recommendations.any? { |existing| existing[:name] == item[:name] } }

    recommendations + popular.first(remaining)
  end

  private

  def scoped_meals(scope, request)
    return scope.where(occasion: request.occasion_enum_value) if request.occasion_enum_value.present?

    scope
  end

  def grouped_recommendations(scope, limit:, source_type:)
    scope
      .joins(:user)
      .group(:name, :occasion)
      .select("meals.name, meals.occasion, COUNT(*) AS total_logged, MAX(users.name) AS sample_friend_name")
      .order(Arel.sql("COUNT(*) DESC, meals.name ASC"))
      .limit(limit)
      .map do |record|
        {
          name: record.name,
          occasion: Meal.occasions.key(record.occasion),
          source_type:,
          friend_name: record.sample_friend_name,
          reason: recommendation_reason(source_type, record.total_logged),
          photo_meal: representative_meal(scope, record.name, record.occasion)
        }
      end
  end

  def recommendation_reason(source_type, total_logged)
    case source_type
    when "following"
      "Someone you follow has been into this lately."
    else
      "Popping up across #{total_logged} recent meals."
    end
  end

  def representative_meal(scope, name, occasion)
    candidates = scope.includes(photo_attachment: :blob).where(name:)
    candidates = candidates.where(occasion:) if occasion.present?
    candidates.order(ate_on: :desc).detect { |meal| meal.photo.attached? } || candidates.order(ate_on: :desc).first
  end
end
