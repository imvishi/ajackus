require "rails_helper"

RSpec.describe Vote do
  let(:event) { create_event }

  it "is valid with an event, user_id and direction" do
    expect(Vote.new(event: event, user_id: "user_1", direction: "up")).to be_valid
  end

  it "requires user_id" do
    expect(Vote.new(event: event, direction: "up")).not_to be_valid
  end

  it "only accepts up or down" do
    expect(Vote.new(event: event, user_id: "user_1", direction: "sideways")).not_to be_valid
  end

  it "requires an event" do
    expect(Vote.new(user_id: "user_1", direction: "up")).not_to be_valid
  end

  it "allows only one vote per user per event" do
    Vote.create!(event: event, user_id: "user_1", direction: "up")

    expect { Vote.create!(event: event, user_id: "user_1", direction: "down") }.to raise_error(ActiveRecord::RecordNotUnique)
  end
end
