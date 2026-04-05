require "test_helper"

class MealTest < ActiveSupport::TestCase
  test "requires the key fields" do
    meal = Meal.new(user: users(:alice))

    assert_not meal.valid?
    assert_includes meal.errors[:name], "can't be blank"
    assert_includes meal.errors[:rating], "can't be blank"
  end

  test "normalizes and titleizes names" do
    meal = Meal.new(
      user: users(:alice),
      name: "   ramen bowl  ",
      source: :home,
      rating: 4,
      ate_on: Date.current,
      occasion: :lunch
    )

    assert meal.valid?
    assert_equal "Ramen Bowl", meal.name
  end

  test "allows historical meals without an occasion" do
    meal = Meal.new(
      user: users(:alice),
      name: "Pasta",
      source: :home,
      rating: 4,
      ate_on: Date.current
    )

    assert meal.valid?
    assert_nil meal.occasion
  end

  test "supports an attached photo" do
    meal = Meal.new(
      user: users(:alice),
      name: "Photo Pasta",
      source: :home,
      rating: 4,
      ate_on: Date.current
    )

    meal.photo.attach(
      io: File.open(file_fixture("meal-photo.png"), "rb"),
      filename: "meal-photo.png",
      content_type: "image/png"
    )

    assert meal.valid?
    assert meal.photo.attached?
  end
end
