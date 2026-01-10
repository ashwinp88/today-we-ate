class Meal < ApplicationRecord
  belongs_to :user

  enum :source, { home: 0, takeout: 1, restaurant: 2 }

  validates :name, :ate_on, :rating, :source, presence: true
  validates :rating, inclusion: { in: 1..5 }
  validates :retry_in_days, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  scope :for_period, ->(range) { where(ate_on: range) }

  before_validation :normalize_name

  private

  def normalize_name
    self.name = name.to_s.strip.titleize if name.present?
  end
end
