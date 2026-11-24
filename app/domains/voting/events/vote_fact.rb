module Voting
  module Events
    # Base for all vote facts: shared schema.
    class VoteFact < Fact
      SCHEMA = {
        event_id: Integer,
        user_id: String
      }.freeze
    end
  end
end
