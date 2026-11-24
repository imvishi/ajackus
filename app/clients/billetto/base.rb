require "net/http"
require "json"

module Billetto
  class Base
    BASE_URL = "https://billetto.dk/api/v3".freeze

    private

    def get(path, params = {})
      url = URI("#{BASE_URL}#{path}")
      url.query = URI.encode_www_form(params) if params.any?

      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      http.open_timeout = 5
      http.read_timeout = 10

      request = Net::HTTP::Get.new(url)
      request["accept"] = "application/json"
      request["Api-Keypair"] = api_keypair

      response = http.request(request)
      raise ApiError, response.code.to_i unless response.is_a?(Net::HTTPSuccess)

      JSON.parse(response.body)
    rescue JSON::ParserError
      raise Error, "Billetto API returned invalid JSON"
    rescue Timeout::Error, SocketError, SystemCallError => e
      raise Error, "Could not connect to Billetto API: #{e.message}"
    end

    def api_keypair
      Rails.application.credentials.dig(:billetto, :api_keypair) ||
        ENV.fetch("BILLETTO_API_KEYPAIR") { raise Error, "Billetto API keypair is missing" }
    end
  end
end
