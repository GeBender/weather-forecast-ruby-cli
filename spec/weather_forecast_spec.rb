# frozen_string_literal: true

require "spec_helper"
require "weather_forecast"

RSpec.describe Weather::WeatherForecast do
  describe "#daily_summary" do
    let(:payload) do
      {
        "hourly" => {
          "time" => [
            "2026-07-15T00:00",
            "2026-07-15T01:00",
            "2026-07-15T02:00",
            "2026-07-16T00:00"
          ],
          "temperature_2m" => [
            18.0,
            20.0,
            22.0,
            30.0
          ]
        }
      }
    end

    it "returns minimum, maximum and average temperature for the requested date" do
      forecast = described_class.new(payload)

      result = forecast.daily_summary(Date.new(2026, 7, 15))

      expect(result[:date]).to eq(Date.new(2026, 7, 15))
      expect(result[:min]).to eq(18.0)
      expect(result[:max]).to eq(22.0)
      expect(result[:average]).to eq(20.0)
    end

    it "returns hourly entries for the requested date" do
      forecast = described_class.new(payload)

      result = forecast.daily_summary(Date.new(2026, 7, 15))

      expect(result[:hourly].size).to eq(3)
      expect(result[:hourly].first).to eq(
        time: DateTime.iso8601("2026-07-15T00:00"),
        temperature: 18.0
      )
    end

    it "raises an error when requested date is outside the forecast range" do
      forecast = described_class.new(payload)

      expect do
        forecast.daily_summary(Date.new(2026, 7, 20))
      end.to raise_error(
        Weather::ForecastDateOutOfRangeError,
        /outside the forecast range/
      )
    end

    it "raises an error when hourly data is missing" do
      forecast = described_class.new({})

      expect do
        forecast.daily_summary(Date.new(2026, 7, 15))
      end.to raise_error(
        Weather::UnexpectedApiResponseError,
        /hourly data/
      )
    end

    it "raises an error when time and temperature arrays have different sizes" do
      invalid_payload = {
        "hourly" => {
          "time" => ["2026-07-15T00:00"],
          "temperature_2m" => [18.0, 19.0]
        }
      }

      forecast = described_class.new(invalid_payload)

      expect do
        forecast.daily_summary(Date.new(2026, 7, 15))
      end.to raise_error(
        Weather::UnexpectedApiResponseError,
        /different sizes/
      )
    end

    it "raises an error when time format is invalid" do
      invalid_payload = {
        "hourly" => {
          "time" => ["invalid-time"],
          "temperature_2m" => [18.0]
        }
      }

      forecast = described_class.new(invalid_payload)

      expect do
        forecast.daily_summary(Date.new(2026, 7, 15))
      end.to raise_error(
        Weather::UnexpectedApiResponseError,
        /Invalid time format/
      )
    end
  end
end