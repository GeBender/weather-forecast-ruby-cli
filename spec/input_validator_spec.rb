# frozen_string_literal: true

require "spec_helper"
require "input_validator"

RSpec.describe Weather::InputValidator do
  describe ".call" do
    it "returns parsed values for valid input" do
      result = described_class.call(
        date: "15-07-2026",
        latitude: "-20.4697",
        longitude: "-54.6201"
      )

      expect(result).to eq(
        date: Date.new(2026, 7, 15),
        latitude: -20.4697,
        longitude: -54.6201
      )
    end

    it "raises an error when date format is invalid" do
      expect do
        described_class.call(
          date: "2026-07-15",
          latitude: "-20.4697",
          longitude: "-54.6201"
        )
      end.to raise_error(Weather::InvalidDateError, /dd-mm-yyyy/)
    end

    it "raises an error when date does not exist" do
      expect do
        described_class.call(
          date: "31-02-2026",
          latitude: "-20.4697",
          longitude: "-54.6201"
        )
      end.to raise_error(Weather::InvalidDateError, /valid date/)
    end

    it "raises an error when latitude is missing" do
      expect do
        described_class.call(
          date: "15-07-2026",
          latitude: nil,
          longitude: "-54.6201"
        )
      end.to raise_error(Weather::InvalidCoordinatesError, /Latitude is required/)
    end

    it "raises an error when latitude is not numeric" do
      expect do
        described_class.call(
          date: "15-07-2026",
          latitude: "abc",
          longitude: "-54.6201"
        )
      end.to raise_error(Weather::InvalidCoordinatesError, /Latitude must be numeric/)
    end

    it "raises an error when latitude is out of range" do
      expect do
        described_class.call(
          date: "15-07-2026",
          latitude: "-91",
          longitude: "-54.6201"
        )
      end.to raise_error(Weather::InvalidCoordinatesError, /Latitude must be between/)
    end

    it "raises an error when longitude is out of range" do
      expect do
        described_class.call(
          date: "15-07-2026",
          latitude: "-20.4697",
          longitude: "181"
        )
      end.to raise_error(Weather::InvalidCoordinatesError, /Longitude must be between/)
    end
  end
end