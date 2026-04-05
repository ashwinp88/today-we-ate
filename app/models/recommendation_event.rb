class RecommendationEvent < ApplicationRecord
  belongs_to :user

  enum :occasion, {
    breakfast: 0,
    brunch: 1,
    lunch: 2,
    dinner: 3
  }, validate: { allow_nil: true }

  validates :event_name, :source_type, presence: true
end
