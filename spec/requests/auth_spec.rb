require "rails_helper"

RSpec.describe "Auth", type: :request do
  let(:credentials) { { email: "a@example.com", password: "secret123" } }

  describe "POST /auth/sign_up" do
    it "creates the user in Clerk" do
      allow(ClerkAuth::SignUp).to receive(:new).with(**credentials).and_return(instance_double(ClerkAuth::SignUp, call: "user_1"))

      post "/auth/sign_up", params: credentials

      expect(response).to have_http_status(:created)
      expect(json).to eq("user_id" => "user_1")
    end

    it "requires email and password" do
      post "/auth/sign_up", params: { email: "a@example.com" }

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "returns Clerk's error message" do
      allow(ClerkAuth::SignUp).to receive(:new).and_raise(ClerkAuth::Error, "Email is taken")

      post "/auth/sign_up", params: credentials

      expect(response).to have_http_status(:unprocessable_entity)
      expect(json).to eq("error" => "Email is taken")
    end
  end

  describe "POST /auth/sign_in" do
    it "returns a session token" do
      result = { token: "jwt", user_id: "user_1", session_id: "sess_1", expires_in: 3600 }
      allow(ClerkAuth::SignIn).to receive(:new).with(**credentials).and_return(instance_double(ClerkAuth::SignIn, call: result))

      post "/auth/sign_in", params: credentials

      expect(json).to include("token" => "jwt", "user_id" => "user_1")
    end

    it "returns 401 for wrong credentials" do
      allow(ClerkAuth::SignIn).to receive(:new).and_raise(ClerkAuth::Error.new("Invalid email or password", status: :unauthorized))

      post "/auth/sign_in", params: credentials

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "POST /auth/sign_out" do
    it "requires sign-in" do
      post "/auth/sign_out"

      expect(response).to have_http_status(:unauthorized)
    end

    it "revokes the current session" do
      sign_in_as("user_1")
      sign_out = instance_double(ClerkAuth::SignOut, call: nil)
      allow(ClerkAuth::SignOut).to receive(:new).with(session_id: "sess_1").and_return(sign_out)

      post "/auth/sign_out"

      expect(response).to have_http_status(:no_content)
      expect(sign_out).to have_received(:call)
    end
  end
end
