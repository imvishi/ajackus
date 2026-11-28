require "rails_helper"

# Stands in for a browser test (the app has no UI): sign up → sign in → vote → sign out → can't vote.
# Only the calls to Clerk are faked; everything in this app runs for real.
RSpec.describe "User journey", type: :request do
  let(:event) { create_event }
  let(:token) { "jwt_1" }
  let(:auth_header) { { "Authorization" => "Bearer #{token}" } }
  let(:session_active) { { value: true } }

  before do
    allow(ClerkAuth::SignUp).to receive(:new).and_return(instance_double(ClerkAuth::SignUp, call: "user_1"))
    allow(ClerkAuth::SignIn).to receive(:new).and_return(
      instance_double(ClerkAuth::SignIn, call: { token: token, user_id: "user_1", session_id: "sess_1", expires_in: 3600 })
    )
    allow(ClerkAuth::SignOut).to receive(:new) do
      instance_double(ClerkAuth::SignOut).tap { |d| allow(d).to receive(:call) { session_active[:value] = false } }
    end
    allow(ClerkAuth::ActiveSession).to receive(:new) { instance_double(ClerkAuth::ActiveSession, call: session_active[:value]) }

    # The token is only accepted when it is the one sign-in returned.
    signed_in = Clerk::Proxy.new(session_claims: { "sub" => "user_1", "sid" => "sess_1" })
    allow_any_instance_of(ApplicationController).to receive(:clerk) do |controller|
      controller.request.authorization == "Bearer #{token}" ? signed_in : Clerk::Proxy.new
    end
  end

  it "lets a user sign up, sign in, vote and sign out" do
    post "/auth/sign_up", params: { email: "a@example.com", password: "secret123" }
    expect(response).to have_http_status(:created)

    post "/auth/sign_in", params: { email: "a@example.com", password: "secret123" }
    expect(json["token"]).to eq(token)

    post "/events/#{event.id}/vote", params: { value: "up" }
    expect(response).to have_http_status(:unauthorized)

    post "/events/#{event.id}/vote", params: { value: "up" }, headers: auth_header
    expect(json.dig("data", "attributes", "upvotes_count")).to eq(1)

    post "/events/#{event.id}/vote", params: { value: "down" }, headers: auth_header
    expect(json.dig("data", "attributes")).to include("upvotes_count" => 0, "downvotes_count" => 1)

    post "/auth/sign_out", headers: auth_header
    expect(response).to have_http_status(:no_content)

    post "/events/#{event.id}/vote", params: { value: "up" }, headers: auth_header
    expect(response).to have_http_status(:unauthorized)
    expect(event.reload.downvotes_count).to eq(1)
  end
end
