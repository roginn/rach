module Rach
  module Provider
    class Anthropic < Base

      def initialize(access_token)
        @client = create_client(access_token)
      end

      def chat(parameters)
        @client.messages(**parameters)
      end

      def self.supports?(model)
        model.start_with?("claude")
      end

      private

      def create_client(access_token)
        ::Anthropic::Client.new(
          access_token: access_token
        )
      end
    end
  end
end
