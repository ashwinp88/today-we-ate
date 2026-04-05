class FriendActivityFeed
  def initialize(user, limit: 6)
    @user = user
    @limit = limit
  end

  def call
    Meal.includes(:user, :meal_likes, { photo_attachment: :blob }, meal_comments: :user)
      .where(user: @user.following)
      .order(created_at: :desc)
      .limit(@limit)
  end
end
