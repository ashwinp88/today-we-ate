class MealComment < ApplicationRecord
  belongs_to :meal
  belongs_to :user

  validates :body, presence: true, length: { maximum: 500 }

  before_validation :normalize_body

  private

  def normalize_body
    self.body = body.to_s.strip
  end
end
