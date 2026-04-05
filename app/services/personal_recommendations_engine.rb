class PersonalRecommendationsEngine
  FALLBACK = {
    name: "Mac And Cheese",
    reason: "You haven't logged enough yet, so here's a comfort-food wildcard.",
    source_type: "fallback",
    occasion: nil,
    fallback: true
  }.freeze

  def call(request)
    meals = scoped_meals(request)
    recommendations = meals
      .group(:name, :occasion)
      .select("name, occasion, AVG(rating) AS average_rating, COUNT(*) AS total_logged, MAX(ate_on) AS last_ate_on")
      .order(Arel.sql("AVG(rating) DESC, COUNT(*) DESC, MAX(ate_on) ASC"))
      .limit(request.limit)
      .map do |record|
        {
          name: record.name,
          occasion: Meal.occasions.key(record.occasion),
          source_type: "personal",
          reason: "You've rated this #{format("%.1f", record.average_rating)}/5 across #{record.total_logged} meals.",
          photo_meal: representative_meal(meals, record.name, record.occasion)
        }
      end

    recommendations.presence || [ FALLBACK ]
  end

  private

  def scoped_meals(request)
    scope = request.user.meals
    scope = scope.where(occasion: request.occasion_enum_value) if request.occasion_enum_value.present?
    scope
  end

  def representative_meal(scope, name, occasion)
    candidates = scope.includes(photo_attachment: :blob).where(name:)
    candidates = candidates.where(occasion:) if occasion.present?
    candidates.order(ate_on: :desc).detect { |meal| meal.photo.attached? } || candidates.order(ate_on: :desc).first
  end
end
