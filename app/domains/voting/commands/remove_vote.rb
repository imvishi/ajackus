module Voting
  module Commands
    # Command: a user removes their vote on an event.
    class RemoveVote
      include ActiveModel::Model
      include ActiveModel::Attributes

      attribute :event_id, :integer
      attribute :user_id, :string

      validates :event_id, :user_id, presence: true
    end
  end
end
