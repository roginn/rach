module Rach
  module Provider
    class Anthropic < Base

      def initialize(access_token, **kwargs)
        @client = create_client(access_token, **kwargs)
      end

      def chat(**parameters)
        @client.messages(**parameters)
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