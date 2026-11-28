require "rails_helper"

RSpec.describe ClerkAuth::ActiveSession do
  let(:sessions) { double("sessions") }

  subject(:active_session) { described_class.new(session_id: "sess_1", sdk: double(sessions: sessions)) }

  def session_with(status)
    double(session: double(status: status))
  end

  it "is true for an active session" do
    allow(sessions).to receive(:get).and_return(session_with(Clerk::Models::Components::SessionStatus::ACTIVE))

    expect(active_session.call).to be(true)
  end

  it "is false for a revoked session" do
    allow(sessions).to receive(:get).and_return(session_with(Clerk::Models::Components::SessionStatus::REVOKED))

    expect(active_session.call).to be(false)
  end

  it "is false when Clerk fails" do
    allow(sessions).to receive(:get).and_raise(Clerk::Models::Errors::ClerkErrors.new(errors: []))

    expect(active_session.call).to be(false)
  end
end
