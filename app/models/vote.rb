class Vote < ApplicationRecord
  enum :direction, { up: 1, down: -1 }, validate: true

  belongs_to :event

  validates :user_id, presence: true
end
