module Voting
  module CommandHandlers
    class UpvoteEventHandler
      def initialize(repository)
        @repository = repository
      end

      def call(command)
        command.validate!
        event = Event.find(command.event_id)

        @repository.with_event_vote(event.id, command.user_id, &:upvote)
      end
    end
  end
end
