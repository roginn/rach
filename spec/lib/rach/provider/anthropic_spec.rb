require 'spec_helper'

RSpec.describe Rach::Provider::Anthropic do
  let(:access_token) { "test_token" }
  let(:anthropic_client) { instance_double(Anthropic::Client) }
  let(:provider) { described_class.new(access_token) }

  let(:default_response) do
    {
      "id" => "msg_123",
      "model" => "claude-3-opus-20240229",
      "usage" => {
        "input_tokens" => 50,
        "output_tokens" => 30
      },
      "content" => [
        {
          "type" => "text",
          "text" => "Hello!"
        }
      ]
    }
  end

  before do
    allow(Anthropic::Client).to receive(:new).and_return(anthropic_client)
    allow(anthropic_client).to receive(:messages).and_return(default_response)
  end

  describe '#chat' do
    let(:test_function) do
      {
        type: :function,
        function: {
          name: "get_current_weather",
          description: "Get the current weather",
          parameters: {
            type: "object",
            properties: {
              location: {
                type: "string",
                description: "The city and state"
              },
              unit: {
                type: "string",
                enum: ["celsius", "fahrenheit"]
              }
            },
            required: ["location"]
          }
        }
      }
    end

    let(:anthropic_response) do
      {
        "id" => "msg_123",
        "model" => "claude-3-opus-20240229",
        "usage" => {
          "input_tokens" => 50,
          "output_tokens" => 30
        },
        "content" => [
          {
            "type" => "text",
            "text" => "Let me check the weather for you."
          },
          {
            "type" => "tool_use",
            "id" => "abc123",
            "name" => "get_current_weather",
            "input" => {
              "location" => "San Francisco, CA",
              "unit" => "celsius"
            }
          }
        ]
      }
    end

    context 'with function calling' do
      let(:parameters) do
        {
          parameters: {
            messages: [{ role: "user", content: "What's the weather in San Francisco?" }],
            tools: [test_function]
          }
        }
      end

      it 'converts OpenAI function schema to Anthropic tool format' do
        expect(anthropic_client).to receive(:messages).with(
          parameters: hash_including(
            tools: [
              {
                name: "get_current_weather",
                description: "Get the current weather",
                input_schema: {
                  type: "object",
                  properties: test_function[:function][:parameters][:properties],
                  required: test_function[:function][:parameters][:required]
                }
              }
            ]
          )
        )

        provider.chat(**parameters)
      end

      it 'converts Anthropic tool calls to OpenAI format' do
        allow(anthropic_client).to receive(:messages).and_return(anthropic_response)
        response = provider.chat(**parameters)

        expect(response.tool_calls).to eq([
          {
            "id" => "abc123",
            "type" => "function",
            "function" => {
              "name" => "get_current_weather",
              "arguments" => "{\"location\":\"San Francisco, CA\",\"unit\":\"celsius\"}"
            }
          }
        ])
      end

      it 'handles responses without tool calls' do
        anthropic_response_without_tools = anthropic_response.merge(
          "content" => [{ "type" => "text", "text" => "Hello!" }]
        )
        allow(anthropic_client).to receive(:messages).and_return(anthropic_response_without_tools)

        response = provider.chat(**parameters)
        expect(response.tool_calls).to be_nil
      end
    end

    context 'with system message' do
      let(:parameters) do
        {
          parameters: {
            messages: [
              { role: "system", content: "You are a weather assistant" },
              { role: "user", content: "What's the weather?" }
            ]
          }
        }
      end

      it 'moves system message to system parameter' do
        expect(anthropic_client).to receive(:messages).with(
          parameters: hash_including(
            system: "You are a weather assistant",
            messages: [{ role: "user", content: "What's the weather?" }]
          )
        )

        provider.chat(**parameters)
      end
    end

    context 'with temperature' do
      let(:parameters) do
        {
          parameters: {
            messages: [{ role: "user", content: "Hi" }],
            temperature: 0.7
          }
        }
      end

      it 'passes temperature to Anthropic client' do
        expect(anthropic_client).to receive(:messages).with(
          parameters: hash_including(temperature: 0.7)
        )

        provider.chat(**parameters)
      end

      it 'clamps temperature between 0 and 1' do
        parameters[:parameters][:temperature] = 1.5

        expect(anthropic_client).to receive(:messages).with(
          parameters: hash_including(temperature: 1.0)
        )

        provider.chat(**parameters)
      end
    end
  end

  describe '.supports?' do
    it 'returns true for Claude models' do
      expect(described_class.supports?("claude-3")).to be true
      expect(described_class.supports?("claude-2")).to be true
    end

    it 'returns false for non-Claude models' do
      expect(described_class.supports?("gpt-4")).to be false
      expect(described_class.supports?("other-model")).to be false
    end
  end
end
