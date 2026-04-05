require "test_helper"

class PersonalRecommendationsEngineTest < ActiveSupport::TestCase
  test "returns highest rated meals for the requested occasion" do
    request = RecommendationRequest.new(user: users(:alice), occasion: :dinner)

    recommendations = PersonalRecommendationsEngine.new.call(request)

    assert_equal "Veggie Tacos", recommendations.first[:name]
    assert_equal "personal", recommendations.first[:source_type]
  end

  test "returns fallback when user has no meals" do
    user = User.create!(provider: "email", uid: "empty@example.com", email: "empty@example.com", password: "password")
    request = RecommendationRequest.new(user:, occasion: :dinner)

    recommendations = PersonalRecommendationsEngine.new.call(request)

    assert_equal "Mac And Cheese", recommendations.first[:name]
    assert recommendations.first[:fallback]
  end
end
