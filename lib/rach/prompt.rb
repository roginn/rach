module Rach
  class Prompt
    attr_reader :content, :model, :temperature, :response_format, :tools

    def initialize(content, model: nil, temperature: 0, response_format: nil, tools: nil)
      @content = content
      @model = model
      @temperature = temperature
      @response_format = response_format
      @tools = tools
    end

    def to_messages
      case content
      when String
        [{ role: "user", content: content }]
      when Message
        [content.to_h]
      when Conversation
        content.to_a
      else
        raise ArgumentError, "content must be a String, Message, or Conversation"
      end
    end
  end
end
