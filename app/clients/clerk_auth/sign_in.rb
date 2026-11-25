module ClerkAuth
  class SignIn < Base
    TOKEN_TTL = 3600 # seconds

    def initialize(email:, password:, **options)
      super(**options)
      @email = email
      @password = password
    end

    def call
      user = find_user
      raise Error.new("Invalid email or password", status: :unauthorized) unless user && valid_password?(user.id)

      clerk_request do
        session = sdk.sessions.create(request: Clerk::Models::Operations::CreateSessionRequest.new(user_id: user.id)).session
        token = sdk.sessions.create_token(
          session_id: session.id,
          body: Clerk::Models::Operations::CreateSessionTokenRequestBody.new(expires_in_seconds: TOKEN_TTL)
        ).object.jwt

        { token: token, user_id: user.id, session_id: session.id, expires_in: TOKEN_TTL }
      end
    end

    private

    def find_user
      request = Clerk::Models::Operations::GetUserListRequest.new(email_address: [ @email ])
      clerk_request { sdk.users.list(request: request).user_list&.first }
    end

    # Clerk answers a wrong password with an error instead of verified: false.
    def valid_password?(user_id)
      body = Clerk::Models::Operations::VerifyPasswordRequestBody.new(password: @password)
      sdk.users.verify_password(user_id: user_id, body: body).object&.verified == true
    rescue Clerk::Models::Errors::ClerkErrors, Clerk::Models::Errors::APIError
      false
    end
  end
end
