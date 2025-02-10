module Gemini
  module Controllers
    class Client
      attr_accessor :model_address

      def model
        @model_address.split('models/').last
      end

      def model=(new_model)
        @model_address = "models/#{new_model}"
      end
    end
  end
end
