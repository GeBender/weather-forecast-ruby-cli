# frozen_string_literal: true

require "json"
require "uri"
require_relative "errors"
require_relative "net_http_client"

module Weather
  class WeatherApiClient
    BASE_URL = "https://api.open-meteo.com/v1/forecast"
    DEFAULT_TIMEOUT = 15

    def initialize(http_client: NetHttpClient.new)
      @http_client = http_client
    end

    def forecast(latitude:, longitude:)
      response = http_client.get(
        build_uri(latitude:, longitude:),
        open_timeout: DEFAULT_TIMEOUT,
        read_timeout: DEFAULT_TIMEOUT
      )

      unless response.status == 200
        raise ApiUnavailableError, "Weather API returned HTTP #{response.status}"
      end

      JSON.parse(response.body)
    rescue JSON::ParserError
      raise UnexpectedApiResponseError, "Weather API returned invalid JSON"
    rescue Errno::ECONNREFUSED,
           Errno::ECONNRESET,
           SocketError,
           Timeout::Error,
           Net::OpenTimeout,
           Net::ReadTimeout => e
      raise ApiUnavailableError, "Weather API request failed: #{e.message}"
    end

    private

    attr_reader :http_client

    def build_uri(latitude:, longitude:)
      uri = URI(BASE_URL)

      uri.query = URI.encode_www_form(
        latitude: latitude,
        longitude: longitude,
        hourly: "temperature_2m",
        timezone: "auto",
        forecast_days: 16
      )

      uri
    end
  end
end