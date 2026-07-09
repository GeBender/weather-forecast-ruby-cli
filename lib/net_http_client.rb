# frozen_string_literal: true

require "net/http"

module Weather
  class NetHttpClient
    Response = Struct.new(:status, :body, keyword_init: true)

    def get(uri, open_timeout:, read_timeout:)
      response = Net::HTTP.start(
        uri.host,
        uri.port,
        use_ssl: uri.scheme == "https",
        open_timeout: open_timeout,
        read_timeout: read_timeout
      ) do |http|
        http.get(uri.request_uri)
      end

      Response.new(
        status: response.code.to_i,
        body: response.body
      )
    end
  end
end