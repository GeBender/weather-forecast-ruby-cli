# frozen_string_literal: true

require "date"
require_relative "errors"

module Weather
  class InputValidator
    DATE_FORMAT = "%d-%m-%Y"
    DATE_REGEX = /\A\d{2}-\d{2}-\d{4}\z/

    def self.call(date:, latitude:, longitude:)
      new(date:, latitude:, longitude:).call
    end

    def initialize(date:, latitude:, longitude:)
      @date = date
      @latitude = latitude
      @longitude = longitude
    end

    def call
      {
        date: parsed_date,
        latitude: parsed_latitude,
        longitude: parsed_longitude
      }
    end

    private

    attr_reader :date, :latitude, :longitude

    def parsed_date
      raise InvalidDateError, "Date is required" if blank?(date)
      raise InvalidDateError, "Invalid date format. Use dd-mm-yyyy" unless date.match?(DATE_REGEX)

      Date.strptime(date, DATE_FORMAT)
    rescue Date::Error
      raise InvalidDateError, "Invalid date. Use a valid date in dd-mm-yyyy format"
    end

    def parsed_latitude
      value = parse_coordinate(latitude, "Latitude")
      return value if value.between?(-90, 90)

      raise InvalidCoordinatesError, "Latitude must be between -90 and 90"
    end

    def parsed_longitude
      value = parse_coordinate(longitude, "Longitude")
      return value if value.between?(-180, 180)

      raise InvalidCoordinatesError, "Longitude must be between -180 and 180"
    end

    def parse_coordinate(value, name)
      raise InvalidCoordinatesError, "#{name} is required" if blank?(value)

      parsed_value = Float(value)
      return parsed_value if parsed_value.finite?

      raise InvalidCoordinatesError, "#{name} must be a finite number"
    rescue ArgumentError, TypeError
      raise InvalidCoordinatesError, "#{name} must be numeric"
    end

    def blank?(value)
      value.nil? || value.to_s.strip.empty?
    end
  end
end