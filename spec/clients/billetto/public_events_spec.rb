require "rails_helper"

RSpec.describe Billetto::PublicEvents do
  subject(:client) { described_class.new(limit: 10) }

  let(:valid) { { "id" => 1, "title" => "Concert", "startdate" => "2026-12-01T20:00:00Z" } }

  it "returns only events with the required fields and a valid start date" do
    allow(client).to receive(:get).and_return("data" => [
      valid,
      valid.merge("title" => ""),
      valid.merge("startdate" => "not a date"),
      "not a hash"
    ])

    expect(client.call).to eq([ valid ])
  end

  it "caps the limit at 100" do
    client = described_class.new(limit: 500)
    allow(client).to receive(:get).and_return("data" => [])

    client.call

    expect(client).to have_received(:get).with("/public/events", limit: 100)
  end

  it "raises ApiError when Billetto answers with an error status" do
    allow_any_instance_of(Net::HTTP).to receive(:request).and_return(Net::HTTPNotFound.new("1.1", "404", "Not Found"))

    expect { client.call }.to raise_error(Billetto::ApiError, /404/)
  end

  it "raises Error when Billetto cannot be reached" do
    allow_any_instance_of(Net::HTTP).to receive(:request).and_raise(SocketError, "no network")

    expect { client.call }.to raise_error(Billetto::Error, /Could not connect/)
  end
end
