class Event < ApplicationRecord
  has_many :votes, dependent: :destroy

  validates :billetto_id, :title, :starts_at, presence: true
end
