module Rach
  module Provider
    class OpenAI < Base

      def initialize(access_token: nil, **kwargs)
        @client = create_client(access_token, **kwargs)
      end

      def chat(**parameters)
        raw_response = @client.chat(**parameters)
        Response.new(
          id: raw_response["id"],
          model: raw_response["model"],
          created_at: Time.at(raw_response["created"]),
          content: raw_response.dig("choices", 0, "message", "content"),
          tool_calls: raw_response.dig("choices", 0, "message", "tool_calls"),
          usage: raw_response["usage"],
          system_fingerprint: raw_response["system_fingerprint"],
          raw_response: raw_response
        )
      end

      def self.supports?(model)
        model.start_with?("gpt", "o1")
      end

      private

      def create_client(access_token, **kwargs)
        ::OpenAI::Client.new(
          access_token: access_token,
          log_errors: true,
          **kwargs
        )
      end
    end
  end
end