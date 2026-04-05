require "test_helper"

class RecommendationTrackerTest < ActiveSupport::TestCase
  test "creates click events" do
    recommendation = { name: "Veggie Tacos", source_type: "personal", occasion: "dinner" }

    assert_difference("RecommendationEvent.count", 1) do
      RecommendationTracker.track_click(user: users(:alice), recommendation:, metadata: { destination: "new_meal" })
    end

    event = RecommendationEvent.last
    assert_equal "recommendation_click", event.event_name
    assert_equal "personal", event.source_type
    assert_equal "Veggie Tacos", event.meal_name
    assert_equal "dinner", event.occasion
  end
end
