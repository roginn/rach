module Rach
  class Response
    attr_reader :id, :model, :created_at, :content, :tool_calls, :usage, 
                :system_fingerprint, :raw_response, :request_params

    def initialize(**options)
      @id = options[:id]
      @model = options[:model]
      @created_at = options[:created_at]
      @content = options[:content]
      @tool_calls = options[:tool_calls]
      @usage = options[:usage]
      @system_fingerprint = options[:system_fingerprint]
      @raw_response = options[:raw_response]
      @request_params = options[:request_params]
    end

    def function_call?
      !tool_calls.nil? && !tool_calls.empty?
    end

    def function_name(tool_call)
      tool_call.dig("function", "name")
    end

    def each_tool_call
      return nil unless function_call?
      tool_calls.each do |tool_call|
        yield tool_call
      end
    end

    def function_arguments(tool_call)
      JSON.parse(tool_call.dig("function", "arguments"))
    rescue JSON::ParserError
      raise ParseError, "Function arguments are not valid JSON"
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

      each_tool_call do |tool_call|
        function = function_class.new
        next unless function.function_name == function_name(tool_call)

        args = function_arguments(tool_call).transform_keys(&:to_sym)
        function.validate_arguments!(args)
        block.call(function, args)
      end

      self
    end

    def on_content(&block)
      block.call(content) if content
      self
    end

    private

    def to_json
      JSON.parse(content)
    rescue JSON::ParserError
      raise ParseError, "Response is not valid JSON"
    end
  end
end
