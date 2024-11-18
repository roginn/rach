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

        @client.messages(parameters: anthropic_params)
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
    end
  end
end