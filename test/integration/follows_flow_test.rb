require "test_helper"

class FollowsFlowTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(provider: "email", uid: "flow@example.com", email: "flow@example.com", password: "password")
    post email_login_path, params: { email: @user.email, password: "password" }
  end

  test "user can follow and unfollow" do
    assert_difference("Follow.count", 1) do
      post user_follow_path(users(:alice))
    end
    assert_redirected_to people_path

    assert_difference("Follow.count", -1) do
      delete user_follow_path(users(:alice))
    end
    assert_redirected_to people_path
  end
end
