require "rails_helper"

RSpec.describe "Votes", type: :request do
  let(:event) { create_event }

  def counts
    json.dig("data", "attributes").values_at("upvotes_count", "downvotes_count")
  end

  context "when not signed in" do
    it "rejects voting" do
      post "/events/#{event.id}/vote", params: { value: "up" }

      expect(response).to have_http_status(:unauthorized)
    end

    it "rejects removing a vote" do
      delete "/events/#{event.id}/vote"

      expect(response).to have_http_status(:unauthorized)
    end

    it "rejects a token whose session was signed out" do
      sign_in_as("user_1")
      allow(ClerkAuth::ActiveSession).to receive(:new).and_return(instance_double(ClerkAuth::ActiveSession, call: false))

      post "/events/#{event.id}/vote", params: { value: "up" }

      expect(response).to have_http_status(:unauthorized)
    end
  end

  context "when signed in" do
    before { sign_in_as("user_1") }

    it "upvotes and returns the new counts" do
      post "/events/#{event.id}/vote", params: { value: "up" }

      expect(response).to have_http_status(:ok)
      expect(counts).to eq([ 1, 0 ])
    end

    it "downvotes" do
      post "/events/#{event.id}/vote", params: { value: "down" }

      expect(counts).to eq([ 0, 1 ])
    end

    it "removes the vote" do
      post "/events/#{event.id}/vote", params: { value: "up" }
      delete "/events/#{event.id}/vote"

      expect(counts).to eq([ 0, 0 ])
    end

    it "stores the Clerk user id in the vote event" do
      post "/events/#{event.id}/vote", params: { value: "up" }

      fact = Rails.configuration.event_store.read.of_type(Voting::Events::EventUpvoted).last
      expect(fact.data).to eq(event_id: event.id, user_id: "user_1")
    end

    it "rejects an invalid value" do
      post "/events/#{event.id}/vote", params: { value: "sideways" }

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "returns 404 for an unknown event" do
      post "/events/0/vote", params: { value: "up" }

      expect(response).to have_http_status(:not_found)
    end

    it "returns 409 when the same vote is changed at the same time" do
      allow(Rails.configuration.command_bus).to receive(:call).and_raise(RubyEventStore::WrongExpectedEventVersion)

      post "/events/#{event.id}/vote", params: { value: "up" }

      expect(response).to have_http_status(:conflict)
    end
  end
end
