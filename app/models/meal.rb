class Meal < ApplicationRecord
  belongs_to :user
  has_one_attached :photo
  has_many :meal_likes, dependent: :destroy
  has_many :meal_comments, -> { order(created_at: :desc) }, dependent: :destroy
  has_many :likers, through: :meal_likes, source: :user

  enum :source, { home: 0, takeout: 1, restaurant: 2 }
  enum :occasion, {
    breakfast: 0,
    brunch: 1,
    lunch: 2,
    dinner: 3
  }, validate: { allow_nil: true }

  validates :name, :ate_on, :rating, :source, presence: true
  validates :rating, numericality: { greater_than_or_equal_to: 0.5, less_than_or_equal_to: 5, multiple_of: 0.5 }
  validates :retry_in_days, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validate :photo_is_reasonable

  scope :for_period, ->(range) { where(ate_on: range) }
  scope :for_occasion, ->(occasion) { occasion.present? ? where(occasion:) : all }

  before_validation :normalize_name

  def liked_by?(user)
    return false unless user

    meal_likes.exists?(user:)
  end

  private

  def normalize_name
    self.name = name.to_s.strip.titleize if name.present?
  end

  def photo_is_reasonable
    return unless photo.attached?

    unless photo.blob.content_type.in?(%w[image/jpeg image/png image/webp image/heic image/heif])
      errors.add(:photo, "must be a JPEG, PNG, WebP, or HEIC image")
    end

    errors.add(:photo, "must be smaller than 8MB") if photo.blob.byte_size > 8.megabytes
  end
end
