# frozen_string_literal: true

require_relative "errors"
require_relative "input_validator"
require_relative "weather_api_client"
require_relative "weather_forecast"
require_relative "weather_presenter"

module Weather
  class WeatherApp
    USAGE = "Usage: ruby bin/weather dd-mm-yyyy latitude longitude [--hourly]"

    def initialize(api_client: WeatherApiClient.new)
      @api_client = api_client
    end

    def call(args)
      options = parse_args(args)

      input = InputValidator.call(
        date: options[:date],
        latitude: options[:latitude],
        longitude: options[:longitude]
      )

      payload = api_client.forecast(
        latitude: input[:latitude],
        longitude: input[:longitude]
      )

      summary = WeatherForecast.new(payload).daily_summary(input[:date])

      WeatherPresenter.new(
        summary: summary,
        latitude: input[:latitude],
        longitude: input[:longitude],
        timezone: payload["timezone"],
        show_hourly: options[:show_hourly]
      ).to_s
    end

    private

    attr_reader :api_client

    def parse_args(args)
      show_hourly = args.delete("--hourly")

      unless args.size == 3
        raise InvalidArgumentsError, USAGE
      end

      {
        date: args[0],
        latitude: args[1],
        longitude: args[2],
        show_hourly: !!show_hourly
      }
    end
  end
end