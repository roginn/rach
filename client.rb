require "openai"

module Rach
  class Client
    def initialize(model: "gpt-3.5-turbo")
      @client = OpenAI::Client.new
      @model = model
    end

    def chat(message, system_prompt: nil)
      messages = build_messages(message, system_prompt)
      response = @client.chat(
        parameters: {
          model: @model,
          messages: messages
        }
      )
      
      Response.new(response)
    end

    # def structured_chat(message, format:, system_prompt: nil)
    #   formatted_prompt = StructuredPrompt.new(format).build(message)
    #   messages = build_messages(formatted_prompt[:messages][0][:content], system_prompt)
    #   response = @client.chat(
    #     parameters: {
    #       model: @model,
    #       messages: messages,
    #       response_format: formatted_prompt[:response_format]
    #     }
    #   )
    #   Response.new(response)
    # end

    private

    def build_messages(message, system_prompt)
      messages = []
      messages << { role: "system", content: system_prompt } if system_prompt
      messages << { role: "user", content: message }
      messages
    end
  end
end
