module Rach
  class Response
    attr_reader :raw_response

    def initialize(response)
      @raw_response = response
    end

    def content
      message&.dig("content")
    end

    def tool_calls
      message&.dig("tool_calls")
    end

    def function_call?
      !tool_calls.nil? && !tool_calls.empty?
    end

    def function_name
      return nil unless function_call?
      tool_calls.first.dig("function", "name")
    end

    def function_arguments
      return nil unless function_call?
      JSON.parse(tool_calls.first.dig("function", "arguments"))
    rescue JSON::ParserError
      raise ParseError, "Function arguments are not valid JSON"
    end

    def usage
      @raw_response["usage"]
    end

    def prompt_tokens
      usage&.fetch("prompt_tokens", 0)
    end

    def completion_tokens
      usage&.fetch("completion_tokens", 0)
    end

    def total_tokens
      usage&.fetch("total_tokens", 0)
    end

    def on_function(function_class = nil, &block)
      return self unless function_call?

      function = function_class.new
      return self unless function.function_name == function_name

      args = function_arguments.transform_keys(&:to_sym)
      function.validate_arguments!(args)
      block.call(function, args)
      self
    end

    def on_content(&block)
      block.call(content) if content
      self
    end

    private

    def message
      @raw_response.dig("choices", 0, "message")
    end

    def to_json
      JSON.parse(content)
    rescue JSON::ParserError
      raise ParseError, "Response is not valid JSON"
    end
  end
end
