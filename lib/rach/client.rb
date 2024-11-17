module Rach
  class Client
    attr_reader :tracker, :client, :model

    def initialize(access_token:, model: "gpt-4o-mini", **kwargs)
      @client = OpenAI::Client.new(log_errors: true, access_token: access_token, **kwargs)
      @model = model
      @tracker = UsageTracker.new
    end

    def chat(prompt, response_format: nil, tools: nil, model: @model, temperature: nil)
      messages = format_messages(prompt)
      formatted_tools = tools&.map(&:function_schema)

      request_params = {
        model:,
        messages: messages,
        response_format: response_format,
        temperature:,
        tools: formatted_tools,
        tool_choice: tools ? "required" : nil,
      }.compact

      response = Response.new(
        @client.chat(parameters: request_params),
        request_params
      )

      @tracker.track(response)
      response
    end

    private

    def format_messages(prompt)
      case prompt
      when String
        [{ role: "user", content: prompt }]
      when Message
        [prompt.to_h]
      when Conversation
        prompt.to_a
      else
        raise ArgumentError, "prompt must be a String, Message, or Conversation"
      end
    end
  end
end
