require "rails_helper"

# Command bus → handler → aggregate → event store → projection.
RSpec.describe "Vote flow" do
  let(:user_id) { "user_123" }
  let(:event) { Event.create!(billetto_id: "1", title: "Concert", starts_at: 1.day.from_now) }

  def vote(command_class)
    Rails.configuration.command_bus.call(command_class.new(event_id: event.id, user_id: user_id))
  end

  def stored_events
    stream = Voting::Aggregates::EventVote.stream_name(event.id, user_id)
    Rails.configuration.event_store.read.stream(stream).to_a
  end

  def counts
    event.reload.then { |e| [ e.upvotes_count, e.downvotes_count ] }
  end

  it "stores EventUpvoted and counts an upvote" do
    vote(Voting::Commands::UpvoteEvent)

    expect(stored_events.map(&:class)).to eq([ Voting::Events::EventUpvoted ])
    expect(counts).to eq([ 1, 0 ])
  end

  it "stores nothing new when the same vote is repeated" do
    2.times { vote(Voting::Commands::UpvoteEvent) }

    expect(stored_events.size).to eq(1)
    expect(counts).to eq([ 1, 0 ])
  end

  it "moves the vote when switching from up to down" do
    vote(Voting::Commands::UpvoteEvent)
    vote(Voting::Commands::DownvoteEvent)

    expect(counts).to eq([ 0, 1 ])
  end

  it "clears the vote when it is removed" do
    vote(Voting::Commands::UpvoteEvent)
    vote(Voting::Commands::RemoveVote)

    expect(counts).to eq([ 0, 0 ])
    expect(event.votes).to be_empty
  end

  it "stores nothing when removing a vote that does not exist" do
    vote(Voting::Commands::RemoveVote)

    expect(stored_events).to be_empty
  end
end
