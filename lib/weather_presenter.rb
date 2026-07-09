# frozen_string_literal: true

module Weather
  class WeatherPresenter
    def initialize(summary:, latitude:, longitude:, timezone:, show_hourly: false)
      @summary = summary
      @latitude = latitude
      @longitude = longitude
      @timezone = timezone
      @show_hourly = show_hourly
    end

    def to_s
      lines = [
        "Weather forecast for #{summary[:date].strftime('%d-%m-%Y')}",
        "Location: #{latitude}, #{longitude}",
        "Timezone: #{timezone || 'not informed'}",
        "",
        "Minimum temperature: #{format_temperature(summary[:min])}",
        "Maximum temperature: #{format_temperature(summary[:max])}",
        "Average temperature: #{format_temperature(summary[:average])}"
      ]

      lines.concat(hourly_lines) if show_hourly

      lines.join("\n")
    end

    private

    attr_reader :summary, :latitude, :longitude, :timezone, :show_hourly

    def hourly_lines
      [
        "",
        "Hourly temperatures:",
        *summary[:hourly].map do |entry|
          "#{entry[:time].strftime('%H:%M')} - #{format_temperature(entry[:temperature])}"
        end
      ]
    end

    def format_temperature(value)
      format("%.1f °C", value)
    end
  end
end