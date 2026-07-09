# frozen_string_literal: true

module Weather
  class Error < StandardError; end

  class InvalidArgumentsError < Error; end
  class InvalidDateError < Error; end
  class InvalidCoordinatesError < Error; end
  class ForecastDateOutOfRangeError < Error; end
  class ApiUnavailableError < Error; end
  class UnexpectedApiResponseError < Error; end
end