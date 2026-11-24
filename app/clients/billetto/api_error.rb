module Billetto
  class ApiError < Error
    attr_reader :status

    def initialize(status)
      @status = status
      super("Billetto API request failed with status #{status}")
    end
  end
end
