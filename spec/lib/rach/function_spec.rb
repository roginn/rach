require 'spec_helper'

RSpec.describe Rach::Function do
  # Create a test function class
  class TestWeatherFunction
    include Rach::Function

    def function_name
      "get_current_weather"
    end

    def function_description
      "Get the current weather for a location"
    end

    def schema
      object do
        string :location, description: "The city and state"
        string :unit, description: "The temperature unit", enum: ["celsius", "fahrenheit"]
      end
    end

    def execute(**args)
      # Test implementation
      { temperature: 72, unit: args[:unit] }
    end
  end

  describe '.find_by_name' do
    it 'finds the correct function class by name' do
      function_class = described_class.find_by_name('get_current_weather')
      expect(function_class).to eq(TestWeatherFunction)
    end

    it 'returns nil for unknown function names' do
      function_class = described_class.find_by_name('nonexistent_function')
      expect(function_class).to be_nil
    end
  end

  describe '.functions' do
    it 'registers functions when module is included' do
      expect(described_class.functions).to include(TestWeatherFunction)
    end
  end

  describe 'function execution' do
    it 'can execute a found function' do
      function_class = described_class.find_by_name('get_current_weather')
      function = function_class.new
      result = function.execute(location: "San Francisco, CA", unit: "fahrenheit")
      
      expect(result).to eq({ temperature: 72, unit: "fahrenheit" })
    end
  end

  describe 'schema validation' do
    let(:function) { TestWeatherFunction.new }
    let(:valid_params) { { location: "San Francisco, CA", unit: "fahrenheit" } }

    it 'generates a valid JSON schema' do
      expected_schema = {
        "type" => "object",
        "properties" => {
          "location" => { 
            "type" => "string",
            "description" => "The city and state"
          },
          "unit" => {
            "type" => "string",
            "enum" => ["celsius", "fahrenheit"],
            "description" => "The temperature unit"
          }
        }
      }

      expect(function.schema.as_json).to match(expected_schema)
    end

    it 'validates correct parameters' do
      expect { function.execute(**valid_params) }.not_to raise_error
    end

    # it 'raises ArgumentError for missing required parameters' do
    #   expect { 
    #     function.validate_arguments!(location: "San Francisco, CA") 
    #   }.to raise_error(ArgumentError, "Invalid arguments for function get_current_weather")
    # end

    it 'raises ArgumentError for invalid enum values' do
      expect { 
        function.validate_arguments!(location: "San Francisco, CA", unit: "kelvin") 
      }.to raise_error(ArgumentError, "Invalid arguments for function get_current_weather")
    end

    # it 'raises ArgumentError for additional properties' do
    #   expect { 
    #     function.validate_arguments!(location: "San Francisco, CA", unit: "celsius", extra: "value") 
    #   }.to raise_error(ArgumentError, "Invalid arguments for function get_current_weather")
    # end

    it 'validates correct parameters without raising error' do
      expect { 
        function.validate_arguments!(valid_params) 
      }.not_to raise_error
    end
  end

  describe '.function_schema' do
    let(:schema) { TestWeatherFunction.function_schema }

    it 'generates valid function schema' do
      expect(schema).to include(
        type: "function",
        function: {
          name: "get_current_weather",
          description: "Get the current weather for a location",
          parameters: {
            type: "object",
            additionalProperties: false,
            required: [:location, :unit],
            properties: {
              location: {
                type: "string",
                description: "The city and state"
              },
              unit: {
                type: "string",
                enum: ["celsius", "fahrenheit"],
                description: "The temperature unit"
              }
            }
          }
        }
      )
    end
  end

  describe 'multiple function calls' do
    # Create a test memory function class
    class TestMemoryFunction
      include Rach::Function

      def function_name
        "update_memory"
      end

      def function_description
        "Update memory with new information"
      end

      def schema
        object do
          string :operation, description: "The operation to perform", enum: ["create", "update"]
          integer :key, description: "The memory key"
          string :value, description: "The memory value"
        end
      end

      def execute(**args)
        # Test implementation
        { status: "success", operation: args[:operation], key: args[:key] }
      end
    end

    it 'executes multiple function calls' do
      response = Rach::Response.new(
        tool_calls: [
          {
            "id" => "call_1",
            "type" => "function",
            "function" => {
              "name" => "update_memory",
              "arguments" => JSON.dump({
                operation: "update",
                key: 0,
                value: "First memory update"
              })
            }
          },
          {
            "id" => "call_2",
            "type" => "function",
            "function" => {
              "name" => "update_memory",
              "arguments" => JSON.dump({
                operation: "create",
                key: 1,
                value: "Second memory creation"
              })
            }
          }
        ]
      )

      call_count = 0
      response.on_function(TestMemoryFunction) do |function, args|
        call_count += 1
        result = function.execute(**args)
        expect(result[:status]).to eq("success")
        expect(result[:operation]).to eq(args[:operation])
        expect(result[:key]).to eq(args[:key])
      end

      expect(call_count).to eq(2)
    end
  end
end
