module ClerkAuth
  class Base
    def initialize(sdk: Clerk::SDK.new)
      @sdk = sdk
    end

    private

    attr_reader :sdk

    # Runs a Clerk SDK call, turning Clerk errors into ClerkAuth::Error.
    def clerk_request
      yield
    rescue Clerk::Models::Errors::ClerkErrors => e
      raise Error, e.errors.map { |err| err.long_message || err.message }.join(", ")
    rescue Clerk::Models::Errors::APIError
      raise Error.new("Clerk request failed", status: :bad_gateway)
    end
  end
end
