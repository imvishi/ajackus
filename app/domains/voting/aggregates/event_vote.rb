module Voting
  module Aggregates
    # Aggregate root: one user's vote on one event.
    # State is rebuilt from its own stream; it decides which fact (if any) a command produces.
    class EventVote
      include AggregateRoot

      def self.stream_name(event_id, user_id)
        "Vote$#{event_id}-#{user_id}"
      end

      def initialize(event_id, user_id)
        @event_id = event_id
        @user_id = user_id
        @value = nil
      end

      def upvote
        apply(Events::EventUpvoted.strict(data: ids)) unless @value == "up"
      end

      def downvote
        apply(Events::EventDownvoted.strict(data: ids)) unless @value == "down"
      end

      def remove
        apply(Events::EventVoteRemoved.strict(data: ids)) if @value
      end

      on(Events::EventUpvoted)     { |_fact| @value = "up" }
      on(Events::EventDownvoted)   { |_fact| @value = "down" }
      on(Events::EventVoteRemoved) { |_fact| @value = nil }

      private

      def ids
        { event_id: @event_id, user_id: @user_id }
      end
    end
  end
end
