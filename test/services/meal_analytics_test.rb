require "test_helper"

class MealAnalyticsTest < ActiveSupport::TestCase
  setup do
    @user = users(:alice)
    @user.meals.destroy_all
  end

  test "top_meals returns most frequent meals per window" do
    travel_to Date.new(2025, 1, 15) do
      2.times do
        @user.meals.create!(name: "Veggie Tacos", source: :home, rating: 5, ate_on: Date.current, retry_in_days: 7)
      end
      @user.meals.create!(name: "Ramen", source: :takeout, rating: 4, ate_on: Date.current - 2.days)

      analytics = MealAnalytics.new(@user)
      top_week = analytics.top_meals[:week]

      assert_equal "Veggie Tacos", top_week.first[:name]
      assert_equal 2, top_week.first[:total]
    end
  end

  test "overdue_favorites orders meals by last date asc" do
    travel_to Date.new(2025, 2, 1) do
      @user.meals.create!(name: "Pizza", source: :restaurant, rating: 5, ate_on: Date.current - 10.days)
      @user.meals.create!(name: "Burger", source: :takeout, rating: 4, ate_on: Date.current - 20.days)

      analytics = MealAnalytics.new(@user)
      overdue = analytics.overdue_favorites(limit: 2)

      assert_equal "Burger", overdue.first[:name]
      assert overdue.first[:last_ate_on] < overdue.last[:last_ate_on]
    end
  end

  test "source_distribution reports counts for all sources" do
    travel_to Date.new(2025, 3, 1) do
      @user.meals.create!(name: "Soup", source: :home, rating: 4, ate_on: Date.current)
      @user.meals.create!(name: "Sushi", source: :restaurant, rating: 5, ate_on: Date.current - 1.day)

      analytics = MealAnalytics.new(@user)
      counts = analytics.source_distribution

      assert_equal 1, counts["home"]
      assert_equal 1, counts["restaurant"]
      assert_equal 0, counts["takeout"]
    end
  end
end
