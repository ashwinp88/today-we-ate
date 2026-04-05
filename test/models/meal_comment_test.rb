require "test_helper"

class MealCommentTest < ActiveSupport::TestCase
  test "strips whitespace from body" do
    comment = MealComment.create!(user: users(:alice), meal: meals(:pizza_restaurant), body: "  Looks great  ")

    assert_equal "Looks great", comment.body
  end
end
