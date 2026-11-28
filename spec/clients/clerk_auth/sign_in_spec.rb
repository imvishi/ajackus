require "rails_helper"

RSpec.describe ClerkAuth::SignIn do
  let(:users) { double("users") }
  let(:sessions) { double("sessions") }
  let(:sdk) { double("sdk", users: users, sessions: sessions) }

  subject(:sign_in) { described_class.new(email: "a@example.com", password: "secret123", sdk: sdk) }

  before do
    allow(users).to receive(:list).and_return(double(user_list: [ double(id: "user_1") ]))
    allow(users).to receive(:verify_password).and_return(double(object: double(verified: true)))
    allow(sessions).to receive(:create).and_return(double(session: double(id: "sess_1")))
    allow(sessions).to receive(:create_token).and_return(double(object: double(jwt: "jwt")))
  end

  it "returns a session token for correct credentials" do
    expect(sign_in.call).to eq(token: "jwt", user_id: "user_1", session_id: "sess_1", expires_in: 3600)
  end

  it "raises 401 for an unknown email" do
    allow(users).to receive(:list).and_return(double(user_list: []))

    expect { sign_in.call }.to raise_error(ClerkAuth::Error) { |e| expect(e.status).to eq(:unauthorized) }
  end

  it "raises 401 for a wrong password" do
    allow(users).to receive(:verify_password).and_raise(Clerk::Models::Errors::ClerkErrors.new(errors: []))

    expect { sign_in.call }.to raise_error(ClerkAuth::Error) { |e| expect(e.status).to eq(:unauthorized) }
    expect(sessions).not_to have_received(:create)
  end
end
