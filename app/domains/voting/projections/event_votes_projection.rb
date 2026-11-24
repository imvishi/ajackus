module Voting
  module Projections
    # Subscriber: projects vote facts into the voting read model
    # (votes table + upvotes_count/downvotes_count on events).
    class EventVotesProjection
      def call(fact)
        event = Event.find(fact.data.fetch(:event_id))
        vote = event.votes.find_or_initialize_by(user_id: fact.data.fetch(:user_id))

        ApplicationRecord.transaction do
          direction = current_direction(fact)
          direction ? vote.update!(direction: direction) : (vote.destroy! if vote.persisted?)

          event.update!(
            upvotes_count: event.votes.up.count,
            downvotes_count: event.votes.down.count
          )
        end
      end

      private

      # The user's vote after this fact, or nil if removed.
      def current_direction(fact)
        case fact
        when Events::EventUpvoted     then "up"
        when Events::EventDownvoted   then "down"
        when Events::EventVoteRemoved then nil
        end
      end
    end
  end
end
