require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "from_omniauth creates or updates a user" do
    auth_hash = OmniAuth::AuthHash.new(
      provider: "google_oauth2",
      uid: "new-user",
      info: { name: "Test Eater", email: "test@example.com" }
    )

    user = User.from_omniauth(auth_hash)

    assert_equal "Test Eater", user.name
    assert_equal "test@example.com", user.email
    assert_equal "google_oauth2", user.provider
  end

  test "from_omniauth updates an existing record" do
    existing = users(:alice)
    auth_hash = OmniAuth::AuthHash.new(
      provider: existing.provider,
      uid: existing.uid,
      info: { name: "Updated", email: "new-email@example.com" }
    )

    user = User.from_omniauth(auth_hash)

    assert_equal existing.id, user.id
    assert_equal "new-email@example.com", user.email
  end
end
