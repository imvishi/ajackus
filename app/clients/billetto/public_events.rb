module Billetto
  class PublicEvents < Base
    REQUIRED_FIELDS = %w[id title startdate].freeze

    def initialize(limit: 10)
      @limit = limit.to_i.clamp(1, 100)
    end

    def call
      data = get("/public/events", limit: @limit)
      events = data.is_a?(Hash) ? Array(data["data"]) : []

      events.select { |event| valid?(event) }
    end

    private

    def valid?(event)
      return false unless event.is_a?(Hash)
      return false if REQUIRED_FIELDS.any? { |field| event[field].blank? }

      Time.iso8601(event["startdate"])
      true
    rescue ArgumentError
      Rails.logger.warn("[Billetto] Skipping event #{event['id']}: invalid startdate")
      false
    end
  end
end
