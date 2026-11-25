module ClerkAuth
  class ActiveSession < Base
    def initialize(session_id:, **options)
      super(**options)
      @session_id = session_id
    end

    def call
      sdk.sessions.get(session_id: @session_id).session.status == Clerk::Models::Components::SessionStatus::ACTIVE
    rescue Clerk::Models::Errors::ClerkErrors, Clerk::Models::Errors::APIError
      false
    end
  end
end
