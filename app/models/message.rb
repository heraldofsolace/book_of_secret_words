class Message < ApplicationRecord
  belongs_to :user
  scope :public_messages, -> { where(public: true) }
  scope :pinned, -> { where(pinned: true) }

  validates :body, presence: true
end
