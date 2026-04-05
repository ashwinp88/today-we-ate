require "test_helper"

class RecommendationEventTest < ActiveSupport::TestCase
  test "requires core fields" do
    event = RecommendationEvent.new(user: users(:alice))

    assert_not event.valid?
    assert_includes event.errors[:event_name], "can't be blank"
    assert_includes event.errors[:source_type], "can't be blank"
  end
end
