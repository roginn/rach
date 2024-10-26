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
        schema_hash[:required] = schema_hash[:properties].keys if schema_hash[:properties]
        schema_hash
      end
    end
  end
end
