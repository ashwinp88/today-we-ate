require "test_helper"

class InsightsFlowTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(provider: "email", uid: "insights@example.com", email: "insights@example.com", password: "password")
    @user.meals.create!(name: "Bowl", source: :home, rating: 4.5, ate_on: Date.current)
    post email_login_path, params: { email: @user.email, password: "password" }
  end

  test "user can open insights" do
    get insights_path

    assert_response :success
    assert_includes response.body, "Patterns worth keeping an eye on"
    assert_includes response.body, "Most repeated"
  end
end
