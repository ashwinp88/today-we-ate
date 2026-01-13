class User < ApplicationRecord
  has_many :meals, dependent: :destroy

  has_secure_password validations: false

  validates :provider, :uid, presence: true
  validates :email, uniqueness: true, allow_blank: true
  validates :email, presence: true, if: -> { provider == "email" }
  validate :password_required_for_email

  def self.from_omniauth(auth_hash)
    find_or_initialize_by(provider: auth_hash.provider, uid: auth_hash.uid).tap do |user|
      info = auth_hash.info || {}
      user.name = info.name.presence || [ info.first_name, info.last_name ].compact.join(" ").presence || user.name
      user.email = info.email.presence || user.email
      user.image_url = info.image if info.image.present?
      user.save!
    end
  end

  def first_name
    name.to_s.split(" ").first.presence || email.to_s.split("@").first || "Friend"
  end

  private

  def password_required_for_email
    return unless provider == "email"
    errors.add(:password, "can't be blank") if password_digest.blank? && password.to_s.blank?
  end
end
