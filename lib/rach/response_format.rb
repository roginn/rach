module Rach
  module ResponseFormat
    def self.included(base)
      require 'json/schema_builder'
      base.include JSON::SchemaBuilder
      base.extend ClassMethods
    end

    module ClassMethods
      def render(schema_name)
        base_schema = new.public_send(schema_name)
        schema = prepare_schema_for_api(base_schema)
        
        {
          type: "json_schema",
          json_schema: {
            name: schema_name.to_s,
            schema:,
            strict: true
          },
        }
      end

      private

      def prepare_schema_for_api(schema)
        schema.additional_properties(false)
        schema_hash = schema.as_json.deep_symbolize_keys
        
        # Recursively set additional_properties: false and required for all objects
        deep_set_object_properties(schema_hash)
        
        schema_hash
      end

      def deep_set_object_properties(schema_hash)
        return unless schema_hash.is_a?(Hash)

        if schema_hash[:type] == "object"
          schema_hash[:additionalProperties] = false
          # Set required to include all properties if properties exist
          if schema_hash[:properties]
            schema_hash[:required] = schema_hash[:properties].keys
          end
        end

        schema_hash.each_value do |value|
          if value.is_a?(Hash)
            deep_set_object_properties(value)
          elsif value.is_a?(Array)
            value.each { |item| deep_set_object_properties(item) }
          end
        end
      end
    end
  end
end
