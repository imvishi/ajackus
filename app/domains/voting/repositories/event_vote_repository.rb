module Voting
  module Repositories
    # Loads an EventVote from its stream, yields it, and stores the new facts.
    class EventVoteRepository
      def initialize(event_store)
        @repository = AggregateRoot::Repository.new(event_store)
      end

      def with_event_vote(event_id, user_id, &block)
        @repository.with_aggregate(Aggregates::EventVote.new(event_id, user_id), Aggregates::EventVote.stream_name(event_id, user_id), &block)
      end
    end
  end
end
