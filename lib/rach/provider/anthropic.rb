module Rach
  module Provider
    class Anthropic < Base

      def initialize(access_token, **kwargs)
        @client = create_client(access_token, **kwargs)
      end

      def chat(**parameters)
        # Extract system message if present
        messages = parameters.dig(:parameters, :messages) || []
        system_message = messages.find { |msg| msg[:role] == "system" }

        # Remove system message from messages array if present
        messages = messages.reject { |msg| msg[:role] == "system" } if system_message

        temperature = (parameters.dig(:parameters, :temperature) || 1).clamp(0, 1)
        max_tokens = parameters.dig(:parameters, :max_tokens) || 1024

        anthropic_params = {
          **parameters[:parameters],
          messages:,
          temperature:,
          max_tokens:, # mandatory!
        }

        raw_response = @client.messages(parameters: anthropic_params)
        Response.new(
          id: raw_response["id"],
          model: raw_response["model"],
          content: raw_response.dig("content", 0, "text"),
          tool_calls: nil,
          usage: {
            "prompt_tokens" => raw_response["usage"]["input_tokens"],
            "completion_tokens" => raw_response["usage"]["output_tokens"],
            "total_tokens" => raw_response["usage"]["input_tokens"] + raw_response["usage"]["output_tokens"]
          },
          raw_response: raw_response
        )
      end

      def self.supports?(model)
        model.start_with?("claude")
      end

      private

      def create_client(access_token, **kwargs)
        ::Anthropic::Client.new(
          access_token: access_token,
          **kwargs
        )
      end

      def parse_response(response)
        response.dig(:content, 0, :text)
      end
    end
  end
end