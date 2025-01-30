module Rach
  module Provider
    class OpenAI < Base

      def initialize(access_token: nil, logger: nil, **kwargs)
        @client = create_client(access_token, **kwargs)
        @logger = logger
      end

      def chat(**parameters)
        parameters = convert_params(parameters)
        raw_response = @client.chat(**parameters)

        if @logger
          @logger.info("Request to OpenAI: #{JSON.pretty_generate(parameters)}")
          @logger.info("Response: #{JSON.pretty_generate(raw_response)}")
        end

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

      def create_client(access_token, **config)
        client_config = {
          access_token: access_token,
          log_errors: true
        }
        client_config.merge!(config)

        ::OpenAI::Client.new(**client_config)
      end

      def convert_params(parameters)
        {
          parameters: {
            **parameters[:parameters],
            tool_choice: parameters.dig(:parameters, :tools) ? "required" : nil
          }.compact
        }
      end
    end
  end
end