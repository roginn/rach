module Rach
  class Client
    def initialize(model: "gpt-4o-mini")
      @client = OpenAI::Client.new
      @model = model
    end

    def chat(prompt, response_format: nil)
      messages = case prompt
      when String
        [{ role: "user", content: prompt }]
      when Message
        [prompt.to_h]
      when Conversation
        prompt.to_a
      else
        raise ArgumentError, "prompt must be a String, Message, or Conversation"
      end

      response = @client.chat(
        parameters: {
          model: @model,
          messages:,
          response_format:,
        }.compact
      )
      
      Response.new(response)
    end
  end
end
