module Rach
  module Function
    def self.included(base)
      require 'json/schema_builder'
      base.include JSON::SchemaBuilder
      base.extend ClassMethods
      
      # Register the function when included
      functions << base
    end

    # Add function registry
    def self.functions
      @functions ||= []
    end

    # Add function lookup method
    def self.find_by_name(name)
      functions.find { |func| func.new.function_name == name }
    end

    module ClassMethods
      def function_schema
        schema = new.schema
        {
          type: "function",
          function: {
            name: new.function_name,
            description: new.function_description,
            parameters: prepare_schema_for_function(schema)
          }
        }
      end

      private

      def prepare_schema_for_function(schema)
        schema.additional_properties(false)
        schema_hash = schema.as_json.deep_symbolize_keys
        
        # Set required fields and additional properties
        deep_set_object_properties(schema_hash)
        
        schema_hash
      end

      def deep_set_object_properties(schema_hash)
        return unless schema_hash.is_a?(Hash)

        if schema_hash[:type] == "object"
          schema_hash[:additionalProperties] = false
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

    # Instance methods that must be implemented by including class
    def schema
      raise NotImplementedError, "#{self.class} must implement #schema"
    end

    def execute(**args)
      raise NotImplementedError, "#{self.class} must implement #execute"
    end

    def function_name
      raise NotImplementedError, "#{self.class} must implement #function_name"
    end

    def function_description
      raise NotImplementedError, "#{self.class} must implement #function_description"
    end

    def validate_arguments!(arguments)
      unless schema.validate(arguments)
        raise ArgumentError, "Invalid arguments for function #{function_name}"
      end
    end
  end
end
