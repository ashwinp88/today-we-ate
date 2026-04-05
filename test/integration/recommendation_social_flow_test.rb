require "test_helper"

class RecommendationSocialFlowTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(provider: "email", uid: "integration@example.com", email: "integration@example.com", name: "Integration User", password: "password", password_confirmation: "password")
    @friend = User.create!(provider: "email", uid: "friend@example.com", email: "friend@example.com", name: "Friend User", password: "password", password_confirmation: "password")
    @friend.meals.create!(name: "Pad Thai", source: :restaurant, occasion: :dinner, rating: 4.5, ate_on: Date.current, notes: "Great noodles")
    @user.meals.create!(name: "Burrito Bowl", source: :home, occasion: :dinner, rating: 5, ate_on: Date.current - 2.days, notes: "Easy win")
    sign_in!
  end

  test "home renders recommendation-first content" do
    get home_path

    assert_response :success
    assert_includes response.body, "What's worth eating"
    assert_includes response.body, "What other people are eating"
    assert_includes response.body, "Tried it"
  end

  test "user can follow someone, like/comment their meal, and log a recommendation click" do
    post user_follow_path(@friend)
    assert_redirected_to people_path
    follow_redirect!

    get home_path
    meal = @friend.meals.order(created_at: :desc).first

    post meal_meal_like_path(meal)
    assert_redirected_to home_path
    assert_equal 1, @user.meal_likes.where(meal: meal).count

    post meal_meal_comments_path(meal), params: { meal_comment: { body: "Looks incredible" } }
    assert_redirected_to home_path
    assert_equal "Looks incredible", meal.meal_comments.order(:created_at).last.body

    post recommendation_selection_path, params: { name: meal.name, source_type: "following", occasion: "dinner" }
    assert_redirected_to new_meal_path(meal: { name: meal.name, occasion: "dinner" })
    assert @user.recommendation_events.where(event_name: "recommendation_click", meal_name: meal.name).exists?
  end

  private

  def sign_in!
    post email_login_path, params: { email: @user.email, password: "password" }
    assert_redirected_to home_path
    follow_redirect!
  end
end
