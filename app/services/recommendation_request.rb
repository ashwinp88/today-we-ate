class RecommendationRequest
  attr_reader :user, :occasion, :limit

  def initialize(user:, occasion:, limit: 2)
    @user = user
    @occasion = occasion.presence&.to_s
    @limit = limit
  end

  def occasion_enum_value
    Meal.occasions[occasion] if occasion.present?
  end
end
