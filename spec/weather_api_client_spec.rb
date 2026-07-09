# frozen_string_literal: true

require "spec_helper"
require "weather_api_client"

RSpec.describe Weather::WeatherApiClient do
  describe "#forecast" do
    FakeResponse = Struct.new(:status, :body, keyword_init: true)

    class FakeHttpClient
      attr_reader :uri, :open_timeout, :read_timeout

      def initialize(response: nil, error: nil)
        @response = response
        @error = error
      end

      def get(uri, open_timeout:, read_timeout:)
        @uri = uri
        @open_timeout = open_timeout
        @read_timeout = read_timeout

        raise @error if @error

        @response
      end
    end

    it "returns parsed JSON when API request succeeds" do
      http_client = FakeHttpClient.new(
        response: FakeResponse.new(
          status: 200,
          body: {
            hourly: {
              time: ["2026-07-15T00:00"],
              temperature_2m: [18.0]
            }
          }.to_json
        )
      )

      client = described_class.new(http_client: http_client)

      result = client.forecast(latitude: -20.4697, longitude: -54.6201)

      expect(result).to eq(
        "hourly" => {
          "time" => ["2026-07-15T00:00"],
          "temperature_2m" => [18.0]
        }
      )
    end

    it "builds the expected Open-Meteo query" do
      http_client = FakeHttpClient.new(
        response: FakeResponse.new(status: 200, body: { hourly: {} }.to_json)
      )

      client = described_class.new(http_client: http_client)
      client.forecast(latitude: -20.4697, longitude: -54.6201)

      query = URI.decode_www_form(http_client.uri.query).to_h

      expect(http_client.uri.to_s).to start_with(
        "https://api.open-meteo.com/v1/forecast"
      )
      expect(query).to include(
        "latitude" => "-20.4697",
        "longitude" => "-54.6201",
        "hourly" => "temperature_2m",
        "timezone" => "auto",
        "forecast_days" => "16"
      )
      expect(http_client.open_timeout).to eq(15)
      expect(http_client.read_timeout).to eq(15)
    end

    it "raises an error when API returns a non-success status" do
      http_client = FakeHttpClient.new(
        response: FakeResponse.new(status: 500, body: "Internal Server Error")
      )

      client = described_class.new(http_client: http_client)

      expect do
        client.forecast(latitude: -20.4697, longitude: -54.6201)
      end.to raise_error(
        Weather::ApiUnavailableError,
        /HTTP 500/
      )
    end

    it "raises an error when HTTP call fails" do
      http_client = FakeHttpClient.new(error: Net::ReadTimeout.new)

      client = described_class.new(http_client: http_client)

      expect do
        client.forecast(latitude: -20.4697, longitude: -54.6201)
      end.to raise_error(
        Weather::ApiUnavailableError,
        /request failed/
      )
    end

    it "raises an error when API returns invalid JSON" do
      http_client = FakeHttpClient.new(
        response: FakeResponse.new(status: 200, body: "not-json")
      )

      client = described_class.new(http_client: http_client)

      expect do
        client.forecast(latitude: -20.4697, longitude: -54.6201)
      end.to raise_error(
        Weather::UnexpectedApiResponseError,
        /invalid JSON/
      )
    end
  end
end