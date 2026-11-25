module ClerkAuth
  # Usage: ClerkAuth::SignUp.new(email:, password:).call  # => "user_2abc..."
  class SignUp < Base
    def initialize(email:, password:, **options)
      super(**options)
      @email = email
      @password = password
    end

    def call
      request = Clerk::Models::Operations::CreateUserRequest.new(email_address: [ @email ], password: @password)
      clerk_request { sdk.users.create(request: request).user.id }
    end
  end
end
