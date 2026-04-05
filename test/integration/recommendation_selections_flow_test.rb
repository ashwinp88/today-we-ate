require "test_helper"

class RecommendationSelectionsFlowTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(provider: "email", uid: "selection@example.com", email: "selection@example.com", password: "password")
    post email_login_path, params: { email: @user.email, password: "password" }
  end

  test "clicking a recommendation logs an event and redirects to new meal" do
    assert_difference("RecommendationEvent.count", 1) do
      post recommendation_selection_path, params: { meal_name: "Veggie Tacos", source_type: "personal", occasion: "dinner" }
    end

    assert_redirected_to new_meal_path(meal: { name: "Veggie Tacos", occasion: "dinner" })
  end
end
