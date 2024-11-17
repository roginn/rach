module Rach
  module Provider
    class Base

      def self.key
        name.split("::").last.downcase.to_sym
      end

      def self.supports?(model)
        raise NotImplementedError
      end

      def chat(parameters)
        raise NotImplementedError
      end

      private

      def create_client(access_token)
        raise NotImplementedError
      end
    end
  end
end
