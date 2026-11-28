require "rails_helper"

RSpec.describe Event do
  it "is valid with billetto_id, title and starts_at" do
    expect(Event.new(billetto_id: "1", title: "Concert", starts_at: Time.current)).to be_valid
  end

  %i[billetto_id title starts_at].each do |field|
    it "requires #{field}" do
      event = Event.new(billetto_id: "1", title: "Concert", starts_at: Time.current, field => nil)

      expect(event).not_to be_valid
      expect(event.errors[field]).to include("can't be blank")
    end
  end

  it "does not allow two events with the same billetto_id" do
    create_event(billetto_id: "1")

    expect { create_event(billetto_id: "1") }.to raise_error(ActiveRecord::RecordNotUnique)
  end

  it "starts with zero votes" do
    expect(create_event).to have_attributes(upvotes_count: 0, downvotes_count: 0)
  end
end
