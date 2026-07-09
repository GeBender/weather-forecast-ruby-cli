# frozen_string_literal: true

require "date"
require_relative "errors"

module Weather
  class WeatherForecast
    def initialize(payload)
      @payload = payload
    end

    def daily_summary(date)
      validate_payload!

      hourly_entries = build_hourly_entries
      daily_entries = hourly_entries.select { |entry| entry[:time].to_date == date }

      if daily_entries.empty?
        raise ForecastDateOutOfRangeError, "Requested date is outside the forecast range"
      end

      temperatures = daily_entries.map { |entry| entry[:temperature] }

      {
        date: date,
        min: temperatures.min,
        max: temperatures.max,
        average: average(temperatures),
        hourly: daily_entries
      }
    end

    private

    attr_reader :payload

    def validate_payload!
      hourly = payload["hourly"]

      unless hourly.is_a?(Hash)
        raise UnexpectedApiResponseError, "Missing or invalid hourly data"
      end

      times = hourly["time"]
      temperatures = hourly["temperature_2m"]

      unless times.is_a?(Array) && temperatures.is_a?(Array)
        raise UnexpectedApiResponseError, "Missing time or temperature arrays"
      end

      unless times.size == temperatures.size
        raise UnexpectedApiResponseError, "Time and temperature arrays have different sizes"
      end
    end

    def build_hourly_entries
      times = payload.fetch("hourly").fetch("time")
      temperatures = payload.fetch("hourly").fetch("temperature_2m")

      times.each_with_index.map do |time, index|
        {
          time: DateTime.iso8601(time),
          temperature: temperatures[index]
        }
      rescue Date::Error
        raise UnexpectedApiResponseError, "Invalid time format in API response"
      end
    end

    def average(values)
      (values.sum.to_f / values.size).round(1)
    end
  end
end