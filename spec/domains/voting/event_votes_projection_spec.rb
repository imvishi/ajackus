require "rails_helper"

RSpec.describe Voting::Projections::EventVotesProjection do
  subject(:projection) { described_class.new }

  let(:event) { Event.create!(billetto_id: "1", title: "Concert", starts_at: 1.day.from_now) }

  def fact(klass, user_id)
    klass.strict(data: { event_id: event.id, user_id: user_id })
  end

  it "sets each user's vote and recounts" do
    projection.call(fact(Voting::Events::EventUpvoted, "user_a"))
    projection.call(fact(Voting::Events::EventDownvoted, "user_b"))

    expect(event.reload).to have_attributes(upvotes_count: 1, downvotes_count: 1)
  end

  it "gives the same result when the same fact is handled twice" do
    upvoted = fact(Voting::Events::EventUpvoted, "user_a")
    2.times { projection.call(upvoted) }

    expect(event.votes.count).to eq(1)
    expect(event.reload.upvotes_count).to eq(1)
  end

  it "deletes the vote row on removal" do
    projection.call(fact(Voting::Events::EventUpvoted, "user_a"))
    projection.call(fact(Voting::Events::EventVoteRemoved, "user_a"))

    expect(event.votes).to be_empty
    expect(event.reload.upvotes_count).to eq(0)
  end
end
