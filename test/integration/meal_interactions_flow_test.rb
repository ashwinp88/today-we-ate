require "test_helper"

class MealInteractionsFlowTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(provider: "email", uid: "interactions@example.com", email: "interactions@example.com", password: "password")
    post email_login_path, params: { email: @user.email, password: "password" }
  end

  test "user can like and comment on a meal" do
    meal = meals(:pizza_restaurant)
    post user_follow_path(meal.user)

    assert_difference([ "MealLike.count", "RecommendationEvent.count" ], 1) do
      post meal_meal_like_path(meal)
    end

    assert_difference([ "MealComment.count", "RecommendationEvent.count" ], 1) do
      post meal_meal_comments_path(meal), params: { meal_comment: { body: "Need this soon" } }
    end
  end
end
