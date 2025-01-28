module Rach
  module Provider
    class Base
      attr_reader :client, :logger

      def initialize(access_token: nil, logger: nil, **config)
        @logger = logger
        @client = create_client(access_token, **config)
      end

      def self.key
        name.split("::").last.downcase.to_sym
      end

      def self.supports?(model)
        raise NotImplementedError
      end

      def chat(**parameters)
        raise NotImplementedError
      end

      private

      def create_client(access_token, **config)
        raise NotImplementedError
      end
    end
  end
end