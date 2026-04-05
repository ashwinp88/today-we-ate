require "test_helper"

class DashboardPresenterTest < ActiveSupport::TestCase
  test "builds a meal and selected occasion context" do
    presenter = DashboardPresenter.new(user: users(:alice), occasion: :lunch)

    assert_equal "lunch", presenter.selected_occasion
    assert_equal "lunch", presenter.meal.occasion
  end

  test "flags cold start users" do
    user = User.create!(provider: "email", uid: "cold@example.com", email: "cold@example.com", password: "password")

    presenter = DashboardPresenter.new(user:, occasion: :dinner)

    assert presenter.cold_start?
    assert_equal "Mac And Cheese", presenter.fallback_recommendation[:name]
  end
end
