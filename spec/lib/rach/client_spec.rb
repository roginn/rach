require 'spec_helper'

RSpec.describe Rach::Client do
  let(:tracker) { instance_double(Rach::UsageTracker) }
  let(:openai_client) { instance_double(OpenAI::Client) }
  let(:anthropic_client) { instance_double(Anthropic::Client) }

  let(:openai_mock_response) do
    {
      "id" => "chat_123",
      "object" => "chat.completion",
      "created" => Time.now.to_i,
      "model" => "gpt-4o-mini",
      "choices" => [{
        "index" => 0,
        "message" => {
          "role" => "assistant",
          "content" => "Test response"
        },
        "finish_reason" => "stop"
      }],
      "usage" => {
        "prompt_tokens" => 10,
        "completion_tokens" => 20,
        "total_tokens" => 30
      }
    }
  end

  let(:anthropic_mock_response) do
    {
      "id" => "msg_01LYzbmmUAcy9gUt65W5iVdF",
      "type" => "message",
      "role" => "assistant",
      "model" => "claude-3-5-sonnet-20241022",
      "content" => [
        {
          "type" => "text",
          "text" => "Test response"
        }
      ],
      "stop_reason" => "end_turn",
      "stop_sequence" => nil,
      "usage" => {
        "input_tokens" => 10,
        "output_tokens" => 20
      }
    }
  end

  before do
    allow(Rach::UsageTracker).to receive(:new).and_return(tracker)
    allow(tracker).to receive(:track)
    allow(OpenAI::Client).to receive(:new).and_return(openai_client)
    allow(Anthropic::Client).to receive(:new).and_return(anthropic_client)
    allow(openai_client).to receive(:chat).and_return(openai_mock_response)
    allow(anthropic_client).to receive(:messages).and_return(anthropic_mock_response)
  end

  describe '#initialize' do
    context 'with single access token' do
      it 'requires model parameter' do
        expect {
          described_class.new(access_token: "sk-123")
        }.to raise_error(ArgumentError)
      end

      it 'initializes with OpenAI model' do
        client = described_class.new(access_token: "sk-123", model: "gpt-4")
        expect(client.providers[:openai]).to be_a(Rach::Provider::OpenAI)
      end

      it 'initializes with Anthropic model' do
        client = described_class.new(access_token: "sk-123", model: "claude-3")
        expect(client.providers[:anthropic]).to be_a(Rach::Provider::Anthropic)
      end
    end

    context 'with multiple access tokens' do
      it 'initializes multiple providers' do
        client = described_class.new(
          providers: {
            openai: { access_token: "sk-123" },
            anthropic: { access_token: "sk-456" }
          }
        )

        expect(client.providers[:openai]).to be_a(Rach::Provider::OpenAI)
        expect(client.providers[:anthropic]).to be_a(Rach::Provider::Anthropic)
      end

      it 'raises error for unknown provider' do
        expect {
          described_class.new(
            providers: { unknown: { access_token: "sk-123" } }
          )
        }.to raise_error(ArgumentError)
      end
    end
  end

  describe "#chat" do

    context 'with string input' do
      it 'creates a prompt and sends to correct provider' do
        client = described_class.new(access_token: "sk-123", model: "gpt-4")

        expect(openai_client).to receive(:chat).with(
          hash_including(
            parameters: {
              messages: [{ role: "user", content: "Hello" }],
              model: "gpt-4",
              temperature: 0
            }
          )
        )

        client.chat("Hello")
      end
    end

    context 'with prompt input' do
      it 'uses prompt configuration and sends to correct provider' do
        client = described_class.new(
          providers: {
            openai: { access_token: "sk-123" },
            anthropic: { access_token: "sk-456" }
          }
        )

        prompt = Rach::Prompt.new(
          "Hello",
          model: "claude-3",
          temperature: 0.7
        )

        expect(anthropic_client).to receive(:messages).with(
          parameters: hash_including(
            messages: [{ role: "user", content: "Hello" }],
            model: "claude-3",
            temperature: 0.7
          )
        )

        client.chat(prompt)
      end

      it 'raises error when no model is specified' do
        client = described_class.new(
          providers: {
            openai: { access_token: "sk-123" },
            anthropic: { access_token: "sk-456" }
          }
        )

        prompt = Rach::Prompt.new("Hello")

        expect {
          client.chat(prompt)
        }.to raise_error(ArgumentError, "No model specified")
      end
    end

    context "when tools are provided" do
      let(:tool) do
        Class.new do
          include Rach::Function

          def function_name
            "test_tool"
          end

          def function_description
            "A test tool"
          end

          def schema
            object do
              # Empty object schema to match original test
            end
          end

          def execute(**args)
            # Test implementation
          end
        end
      end

      it "sets tool_choice to 'required' when tools are present" do
        client = described_class.new(access_token: "fake-token", model: "gpt-4o-mini")

        expect(openai_client).to receive(:chat).with(
          parameters: hash_including(tool_choice: "required")
        )

        client.chat("test prompt", tools: [tool])
      end

      it "sets tool_choice to nil when tools are not present" do
        client = described_class.new(access_token: "fake-token", model: "gpt-4o-mini")

        expect(openai_client).to receive(:chat).with(
          parameters: hash_not_including(:tool_choice)
        )

        client.chat("test prompt")
      end
    end
  end
end