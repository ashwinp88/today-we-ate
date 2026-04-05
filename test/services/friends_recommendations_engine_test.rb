require "test_helper"

class FriendsRecommendationsEngineTest < ActiveSupport::TestCase
  test "returns followed users meals first" do
    request = RecommendationRequest.new(user: users(:alice), occasion: :dinner)

    recommendations = FriendsRecommendationsEngine.new.call(request)

    assert_equal "Brick Oven Pizza", recommendations.first[:name]
    assert_equal "following", recommendations.first[:source_type]
  end

  test "fills remaining slots with popular meals" do
    outsider = User.create!(provider: "email", uid: "outsider@example.com", email: "outsider@example.com", password: "password")
    outsider.meals.create!(name: "Hot Chicken", source: :restaurant, occasion: :dinner, rating: 4.5, ate_on: Date.current)
    request = RecommendationRequest.new(user: users(:alice), occasion: :dinner)

    recommendations = FriendsRecommendationsEngine.new.call(request)

    assert recommendations.any? { |item| item[:source_type] == "popular" && item[:name] == "Hot Chicken" }
  end
end
