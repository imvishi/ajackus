module SpecHelpers
  def create_event(**attrs)
    Event.create!({ billetto_id: SecureRandom.hex(4), title: "Concert", starts_at: 1.day.from_now }.merge(attrs))
  end

  # Pretends a valid, active Clerk session token was sent for this user.
  def sign_in_as(user_id)
    proxy = Clerk::Proxy.new(session_claims: { "sub" => user_id, "sid" => "sess_1" })
    allow_any_instance_of(ApplicationController).to receive(:clerk).and_return(proxy)
    allow(ClerkAuth::ActiveSession).to receive(:new).and_return(instance_double(ClerkAuth::ActiveSession, call: true))
  end

  def json
    JSON.parse(response.body)
  end
end

RSpec.configure { |config| config.include SpecHelpers }
