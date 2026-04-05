class RecommendationTracker
  def self.track_impression(user:, recommendation:)
    create_event(user:, recommendation:, event_name: "recommendation_impression")
  end

  def self.track_click(user:, recommendation:, metadata: {})
    create_event(user:, recommendation:, event_name: "recommendation_click", metadata:)
  end

  def self.track_social_action!(user:, event_name:, meal_name:, metadata: {})
    recommendation = { name: meal_name, source_type: "social", occasion: metadata[:occasion] }
    create_event(user:, recommendation:, event_name:, metadata:)
  end

  def self.create_event(user:, recommendation:, event_name:, metadata: {})
    recommendation = recommendation.symbolize_keys

    RecommendationEvent.create!(
      user:,
      event_name:,
      source_type: recommendation.fetch(:source_type),
      meal_name: recommendation[:name],
      occasion: recommendation[:occasion].presence,
      metadata: metadata.compact
    )
  end
end
