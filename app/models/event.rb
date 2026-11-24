class Event < ApplicationRecord
  validates :billetto_id, :title, :starts_at, presence: true
end
