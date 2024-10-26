require 'spec_helper'

RSpec.describe Rach::ResponseFormat do
  let(:test_schema_class) do
    Class.new do
      include Rach::ResponseFormat

      def schema
        object do
          string :name
          integer :age
          array :hobbies do
            items type: :string
          end
        end
      end
    end
  end

  describe '.render' do
    subject(:rendered_schema) { test_schema_class.render(:schema) }

    it 'returns a properly formatted schema hash' do
      expect(rendered_schema).to eq({
        type: "json_schema",
        json_schema: {
          name: "schema",
          schema: {
            type: "object",
            properties: {
              name: { type: "string" },
              age: { type: "integer" },
              hobbies: {
                type: "array",
                items: { type: "string" }
              }
            },
            required: [:name, :age, :hobbies],
            additionalProperties: false
          },
          strict: true
        }
      })
    end
  end

  describe 'schema validation' do
    let(:schema_class) { test_schema_class.new }

    it 'creates a valid JSON schema' do
      schema = schema_class.schema
      expect { schema.as_json }.not_to raise_error
    end

    it 'includes JSON::SchemaBuilder methods' do
      expect(schema_class).to respond_to(:object)
      expect(schema_class).to respond_to(:string)
      expect(schema_class).to respond_to(:integer)
      expect(schema_class).to respond_to(:array)
    end
  end
end
