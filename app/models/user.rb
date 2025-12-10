class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, reconfirmable: true

  has_many :messages, dependent: :destroy

  # -----------------------------
  # Username validations
  # -----------------------------
  validates :username,
            presence: true,
            uniqueness: { case_sensitive: false },
            length: { minimum: 3, maximum: 20 },
            format: {
              with: /\A[a-zA-Z0-9._]+\z/,
              message: "may only contain letters, numbers, underscores, and dots"
            }

  # Prevent username from being an email
  validate :username_cannot_look_like_email

  private

  def username_cannot_look_like_email
    if username.present? && URI::MailTo::EMAIL_REGEXP.match?(username)
      errors.add(:username, "cannot be an email address")
    end
  end
end
