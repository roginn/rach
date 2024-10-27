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
        string :location, "The city and state"
        string :unit, "The temperature unit", enum: ["celsius", "fahrenheit"]
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
            "type" => "string"
          },
          "unit" => {
            "type" => "string",
            "enum" => ["celsius", "fahrenheit"]
          }
        }
      }

      expect(function.schema.as_json).to match(expected_schema)
    end

    it 'validates correct parameters' do
      expect { function.execute(**valid_params) }.not_to raise_error
    end
  end
end
