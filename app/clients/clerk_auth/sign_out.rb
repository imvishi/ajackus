module ClerkAuth
  # Usage: ClerkAuth::SignOut.new(session_id:).call  # revokes the Clerk session
  class SignOut < Base
    def initialize(session_id:, **options)
      super(**options)
      @session_id = session_id
    end

    def call
      clerk_request { sdk.sessions.revoke(session_id: @session_id) }
    end
  end
end
