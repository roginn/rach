require 'gemini-ai'

module Rach
  module Provider
    class Google < Base

      def initialize(access_token: nil, logger: nil, **kwargs)
        @client = create_client(access_token, **kwargs)
        @logger = logger
      end

      def chat(**parameters)
        messages = parameters.dig(:parameters, :messages) || []
        system_message = messages.find { |msg| msg[:role] == "system" }
        messages = messages.reject { |msg| msg[:role] == "system" } if system_message

        # Convert messages to Gemini format
        contents = messages.map do |msg|
          {
            role: msg[:role] == "assistant" ? "model" : "user",
            parts: { text: msg[:content] }
          }
        end

        # If there's a system message, prepend it to user's first message
        if system_message
          first_user_message = contents.find { |msg| msg[:role] == "user" }
          if first_user_message
            first_user_message[:parts][:text] = "#{system_message[:content]}\n\n#{first_user_message[:parts][:text]}"
          end
        end

        if @logger
          @logger.info("Making API call to Google Gemini")
          @logger.info("Request parameters: #{contents.inspect}")
        end

        raw_response = @client.generate_content({ contents: contents })

        if @logger
          @logger.info("Response: #{raw_response.inspect}")
        end

        Response.new(
          id: raw_response["candidates"][0]["content"]["parts"][0]["text"],
          model: raw_response["modelVersion"],
          content: raw_response["candidates"][0]["content"]["parts"][0]["text"],
          usage: {
            "prompt_tokens" => raw_response["usageMetadata"]["promptTokenCount"],
            "completion_tokens" => raw_response["usageMetadata"]["candidatesTokenCount"],
            "total_tokens" => raw_response["usageMetadata"]["totalTokenCount"]
          },
          raw_response: raw_response
        )
      end

      def self.supports?(model)
        model.start_with?("gemini")
      end

      private

      def create_client(access_token, **config)
        client_config = {
          credentials: {
            service: 'generative-language-api',
            api_key: access_token
          },
          options: { model: 'gemini-pro' }
        }
        client_config[:options].merge!(config)

        ::Gemini.new(**client_config)
      end
    end
  end
end 