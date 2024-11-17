require 'spec_helper'

RSpec.describe Rach::Client do
  let(:tracker) { instance_double(Rach::UsageTracker) }
  let(:openai_client) { instance_double(OpenAI::Client) }
  let(:anthropic_client) { instance_double(Anthropic::Client) }
  
  before do
    allow(Rach::UsageTracker).to receive(:new).and_return(tracker)
    allow(tracker).to receive(:track)
    allow(OpenAI::Client).to receive(:new).and_return(openai_client)
    allow(Anthropic::Client).to receive(:new).and_return(anthropic_client)
    allow(openai_client).to receive(:chat)
    allow(anthropic_client).to receive(:messages)
  end

  describe '#initialize' do
    context 'with single access token' do
      it 'requires model parameter' do
        expect {
          described_class.new(access_token: "sk-123")
        }.to raise_error(ArgumentError, "Model must be specified when using single access token")
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
          access_token: {
            openai: "sk-123",
            anthropic: "sk-456"
          }
        )

        expect(client.providers[:openai]).to be_a(Rach::Provider::OpenAI)
        expect(client.providers[:anthropic]).to be_a(Rach::Provider::Anthropic)
      end

      it 'raises error for unknown provider' do
        expect {
          described_class.new(
            access_token: { unknown: "sk-123" }
          )
        }.to raise_error(ArgumentError, "Unknown provider: unknown")
      end
    end
  end

  describe '#chat' do
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
          access_token: {
            openai: "sk-123",
            anthropic: "sk-456"
          }
        )

        prompt = Rach::Prompt.new(
          "Hello",
          model: "claude-3",
          temperature: 0.7
        )

        expect(anthropic_client).to receive(:messages).with(
          parameters: hash_including(
            model: "claude-3",
            messages: [{ role: "user", content: "Hello" }],
            temperature: 0.7
          )
        )

        client.chat(prompt)
      end

      it 'raises error when no model is specified' do
        client = described_class.new(
          access_token: {
            openai: "sk-123",
            anthropic: "sk-456"
          }
        )

        prompt = Rach::Prompt.new("Hello")

        expect {
          client.chat(prompt)
        }.to raise_error(ArgumentError, "No model specified")
      end
    end
  end
end 