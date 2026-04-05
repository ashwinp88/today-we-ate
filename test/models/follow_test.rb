require "test_helper"

class FollowTest < ActiveSupport::TestCase
  test "rejects self follow" do
    follow = Follow.new(follower: users(:alice), followed: users(:alice))

    assert_not follow.valid?
    assert_includes follow.errors[:followed_id], "can't be yourself"
  end

  test "rejects duplicate follow" do
    duplicate = Follow.new(follower: users(:alice), followed: users(:bob))

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:followed_id], "has already been taken"
  end
end
