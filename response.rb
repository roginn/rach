module Rach
  class Response
    attr_reader :raw_response

    def initialize(response)
      @raw_response = response
    end

    def content
      @raw_response.dig("choices", 0, "message", "content")
    end

    def to_json
      JSON.parse(content)
    rescue JSON::ParserError
      raise ParseError, "Response is not valid JSON"
    end
  end
end
