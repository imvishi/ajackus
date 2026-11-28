require "rails_helper"

RSpec.describe Events::SyncFromBilletto do
  let(:billetto_event) do
    { "id" => 42, "title" => "Concert", "description" => "Live", "url" => "https://billetto.dk/e/42",
      "startdate" => "2026-12-01T20:00:00Z", "enddate" => "2026-12-01T23:00:00Z" }
  end

  def stub_billetto(events)
    allow(Billetto::PublicEvents).to receive(:new).and_return(instance_double(Billetto::PublicEvents, call: events))
  end

  it "saves events and returns how many were synced" do
    stub_billetto([ billetto_event ])

    expect(described_class.new.call).to eq(1)
    expect(Event.find_by(billetto_id: "42")).to have_attributes(title: "Concert", description: "Live")
  end

  it "updates an existing event instead of creating a duplicate" do
    stub_billetto([ billetto_event ])
    described_class.new.call
    stub_billetto([ billetto_event.merge("title" => "New title") ])
    described_class.new.call

    expect(Event.where(billetto_id: "42").pluck(:title)).to eq([ "New title" ])
  end

  it "does nothing when Billetto returns no events" do
    stub_billetto([])

    expect(described_class.new.call).to eq(0)
    expect(Event.count).to eq(0)
  end
end
