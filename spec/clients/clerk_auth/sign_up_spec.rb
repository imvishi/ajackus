require "rails_helper"

RSpec.describe ClerkAuth::SignUp do
  let(:users) { double("users") }

  subject(:sign_up) { described_class.new(email: "a@example.com", password: "secret123", sdk: double(users: users)) }

  it "returns the new Clerk user id" do
    allow(users).to receive(:create).and_return(double(user: double(id: "user_1")))

    expect(sign_up.call).to eq("user_1")
  end

  it "turns Clerk validation errors into a 422 with Clerk's message" do
    error = Clerk::Models::Errors::ClerkErrors.new(errors: [ double(long_message: "Email is taken", message: "taken") ])
    allow(users).to receive(:create).and_raise(error)

    expect { sign_up.call }.to raise_error(ClerkAuth::Error, "Email is taken") { |e| expect(e.status).to eq(:unprocessable_entity) }
  end

  it "turns Clerk outages into a 502" do
    allow(users).to receive(:create).and_raise(Clerk::Models::Errors::APIError.new(status_code: 500, body: "", raw_response: nil))

    expect { sign_up.call }.to raise_error(ClerkAuth::Error) { |e| expect(e.status).to eq(:bad_gateway) }
  end
end
