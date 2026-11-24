module Voting
  FACTS = [
    Events::EventUpvoted, Events::EventDownvoted, Events::EventVoteRemoved
  ].freeze

  def self.register_commands(command_bus, event_store)
    repository = Repositories::EventVoteRepository.new(event_store)

    command_bus.register(Commands::UpvoteEvent, CommandHandlers::UpvoteEventHandler.new(repository))
    command_bus.register(Commands::DownvoteEvent, CommandHandlers::DownvoteEventHandler.new(repository))
    command_bus.register(Commands::RemoveVote, CommandHandlers::RemoveVoteHandler.new(repository))
  end

  # subscriber => facts it handles
  def self.subscriptions
    { Projections::EventVotesProjection.new => FACTS }
  end
end
