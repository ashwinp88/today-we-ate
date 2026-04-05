class MealLike < ApplicationRecord
  belongs_to :meal
  belongs_to :user

  validates :meal_id, uniqueness: { scope: :user_id }
end
