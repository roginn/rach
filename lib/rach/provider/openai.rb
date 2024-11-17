module Rach
  module Provider
    class OpenAI < Base

      def initialize(access_token, **kwargs)
        @client = create_client(access_token, **kwargs)
      end

      def chat(parameters)
        @client.chat(parameters)
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