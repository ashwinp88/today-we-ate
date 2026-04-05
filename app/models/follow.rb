class Follow < ApplicationRecord
  belongs_to :follower, class_name: "User"
  belongs_to :followed, class_name: "User"

  validates :followed_id, uniqueness: { scope: :follower_id }
  validate :cannot_follow_yourself

  private

  def cannot_follow_yourself
    errors.add(:followed_id, "can't be yourself") if follower_id.present? && follower_id == followed_id
  end
end
