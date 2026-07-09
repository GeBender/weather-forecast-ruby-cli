# frozen_string_literal: true

require "spec_helper"
require "weather_app"

RSpec.describe Weather::WeatherApp do
  describe "#call" do
    FakeApiClient = Struct.new(:payload, :error, keyword_init: true) do
      attr_reader :latitude, :longitude

      def forecast(latitude:, longitude:)
        @latitude = latitude
        @longitude = longitude

        raise error if error

        payload
      end
    end

    let(:payload) do
      {
        "timezone" => "America/Campo_Grande",
        "hourly" => {
          "time" => [
            "2026-07-15T00:00",
            "2026-07-15T01:00",
            "2026-07-15T02:00"
          ],
          "temperature_2m" => [18.0, 20.0, 22.0]
        }
      }
    end

    it "returns a formatted forecast summary" do
      api_client = FakeApiClient.new(payload: payload)
      app = described_class.new(api_client: api_client)

      output = app.call(["15-07-2026", "-20.4697", "-54.6201"])

      expect(output).to include("Weather forecast for 15-07-2026")
      expect(output).to include("Location: -20.4697, -54.6201")
      expect(output).to include("Timezone: America/Campo_Grande")
      expect(output).to include("Minimum temperature: 18.0 °C")
      expect(output).to include("Maximum temperature: 22.0 °C")
      expect(output).to include("Average temperature: 20.0 °C")

      expect(api_client.latitude).to eq(-20.4697)
      expect(api_client.longitude).to eq(-54.6201)
    end

    it "includes hourly temperatures when requested" do
      api_client = FakeApiClient.new(payload: payload)
      app = described_class.new(api_client: api_client)

      output = app.call(["15-07-2026", "-20.4697", "-54.6201", "--hourly"])

      expect(output).to include("Hourly temperatures:")
      expect(output).to include("00:00 - 18.0 °C")
      expect(output).to include("01:00 - 20.0 °C")
      expect(output).to include("02:00 - 22.0 °C")
    end

    it "raises an error when arguments are incomplete" do
      app = described_class.new(api_client: FakeApiClient.new(payload: payload))

      expect do
        app.call(["15-07-2026", "-20.4697"])
      end.to raise_error(Weather::InvalidArgumentsError, /Usage/)
    end

    it "raises an error when API call fails" do
      api_client = FakeApiClient.new(
        error: Weather::ApiUnavailableError.new("Weather API request failed")
      )

      app = described_class.new(api_client: api_client)

      expect do
        app.call(["15-07-2026", "-20.4697", "-54.6201"])
      end.to raise_error(Weather::ApiUnavailableError, /request failed/)
    end
  end
end