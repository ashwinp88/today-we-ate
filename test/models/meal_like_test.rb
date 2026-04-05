require "test_helper"

class MealLikeTest < ActiveSupport::TestCase
  test "requires uniqueness per user and meal" do
    MealLike.create!(user: users(:alice), meal: meals(:pizza_restaurant))
    duplicate = MealLike.new(user: users(:alice), meal: meals(:pizza_restaurant))

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:meal_id], "has already been taken"
  end
end
