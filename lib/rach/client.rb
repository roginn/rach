module Rach
  class Client
    attr_reader :tracker, :client, :model

    def initialize(model: "gpt-4o-mini")
      @client = OpenAI::Client.new(log_errors: true)
      @model = model
      @tracker = UsageTracker.new
    end

    def chat(prompt, response_format: nil, tools: nil)
      messages = format_messages(prompt)
      
      response = Response.new(
        @client.chat(
          parameters: {
            model: @model,
            messages:,
            response_format:,
            tools:,
          }.compact
        )
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
