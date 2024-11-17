module Rach
  module Provider
    class OpenAI < Base

      def initialize(access_token)
        @client = create_client(access_token)
      end

      def chat(parameters)
        @client.chat(parameters)
      end

      def self.supports?(model)
        model.start_with?("gpt", "o1")
      end

      private

      def create_client(access_token)
        ::OpenAI::Client.new(
          access_token: access_token,
          log_errors: true
        )
      end
    end
  end
end
