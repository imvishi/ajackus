require "rails_helper"

RSpec.describe "Events", type: :request do
  describe "GET /events" do
    it "lists events sorted by start date with pagination info" do
      later = create_event(title: "Later", starts_at: 2.days.from_now)
      sooner = create_event(title: "Sooner", starts_at: 1.day.from_now)

      get "/events", params: { per_page: 1 }

      expect(response).to have_http_status(:ok)
      expect(json["data"].map { |e| e["id"] }).to eq([ sooner.id.to_s ])
      expect(json["meta"]).to include("total_count" => 2, "total_pages" => 2)
      expect(later).to be_persisted
    end
  end

  describe "GET /events/:id" do
    it "shows the event with its vote counts" do
      event = create_event(title: "Concert")

      get "/events/#{event.id}"

      expect(json.dig("data", "attributes")).to include("title" => "Concert", "upvotes_count" => 0, "downvotes_count" => 0)
    end

    it "returns 404 for an unknown event" do
      get "/events/0"

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /events/sync" do
    it "requires sign-in" do
      post "/events/sync"

      expect(response).to have_http_status(:unauthorized)
    end

    it "syncs events for a signed-in user" do
      sign_in_as("user_1")
      allow(Events::SyncFromBilletto).to receive(:new).and_return(instance_double(Events::SyncFromBilletto, call: 3))

      post "/events/sync"

      expect(json).to eq("synced" => 3)
    end

    it "returns 502 when Billetto fails" do
      sign_in_as("user_1")
      allow(Events::SyncFromBilletto).to receive(:new).and_raise(Billetto::Error, "Billetto is down")

      post "/events/sync"

      expect(response).to have_http_status(:bad_gateway)
      expect(json).to eq("error" => "Billetto is down")
    end
  end
end
