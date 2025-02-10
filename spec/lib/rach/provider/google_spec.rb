require 'spec_helper'

RSpec.describe Rach::Provider::Google do
  let(:access_token) { "test_token" }
  let(:gemini_client) { double("Gemini") }
  let(:provider) { described_class.new(access_token:) }

  let(:default_response) do
    {
      "candidates" => [
        {
          "content" => {
            "parts" => [
              { "text" => "Hello!" }
            ],
            "role" => "model"
          },
          "finishReason" => "STOP",
          "avgLogprobs" => -0.003976271233775399
        }
      ],
      "usageMetadata" => {
        "promptTokenCount" => 2,
        "candidatesTokenCount" => 11,
        "totalTokenCount" => 13,
        "promptTokensDetails" => [{ "modality" => "TEXT", "tokenCount" => 2 }],
        "candidatesTokensDetails" => [{ "modality" => "TEXT", "tokenCount" => 11 }]
      },
      "modelVersion" => "gemini-2.0-flash"
    }
  end

  describe '#chat' do
    before do
      allow(Gemini).to receive(:new).and_return(gemini_client)
      allow(gemini_client).to receive(:generate_content).and_return(default_response)
      allow(gemini_client).to receive(:model).and_return("gemini-2.0-flash")
      allow(gemini_client).to receive(:model=)
    end

    context 'with basic message' do
      let(:parameters) do
        {
          parameters: {
            messages: [{ role: "user", content: "Hello!" }]
          }
        }
      end

      it 'converts messages to Gemini format' do
        expect(gemini_client).to receive(:generate_content).with(
          hash_including(
            contents: [
              {
                role: "user",
                parts: { text: "Hello!" }
              }
            ]
          )
        )

        provider.chat(**parameters)
      end

      it 'returns formatted response' do
        response = provider.chat(**parameters)

        expect(response.id).to eq("Hello!")
        expect(response.model).to eq("gemini-2.0-flash")
        expect(response.content).to eq("Hello!")
        expect(response.usage).to eq(
          "prompt_tokens" => 2,
          "completion_tokens" => 11,
          "total_tokens" => 13
        )
      end
    end

    context 'with system message' do
      let(:parameters) do
        {
          parameters: {
            messages: [
              { role: "system", content: "You are a helpful assistant" },
              { role: "user", content: "Hello!" }
            ]
          }
        }
      end

      it 'prepends system message to first user message' do
        expect(gemini_client).to receive(:generate_content).with(
          hash_including(
            contents: [
              {
                role: "user",
                parts: { text: "You are a helpful assistant\n\nHello!" }
              }
            ]
          )
        )

        provider.chat(**parameters)
      end
    end

    context 'with assistant messages' do
      let(:parameters) do
        {
          parameters: {
            messages: [
              { role: "user", content: "Hi!" },
              { role: "assistant", content: "Hello!" },
              { role: "user", content: "How are you?" }
            ]
          }
        }
      end

      it 'converts assistant messages to model role' do
        expect(gemini_client).to receive(:generate_content).with(
          hash_including(
            contents: [
              { role: "user", parts: { text: "Hi!" } },
              { role: "model", parts: { text: "Hello!" } },
              { role: "user", parts: { text: "How are you?" } }
            ]
          )
        )

        provider.chat(**parameters)
      end
    end
  end

  describe '.supports?' do
    it 'returns true for Gemini models' do
      expect(described_class.supports?("gemini-pro")).to be true
      expect(described_class.supports?("gemini-1.0")).to be true
    end

    it 'returns false for non-Gemini models' do
      expect(described_class.supports?("gpt-4")).to be false
      expect(described_class.supports?("claude-3")).to be false
    end
  end

  describe 'Gemini client monkey patch' do
    let(:real_client) do
      Gemini.new(
        credentials: {
          service: 'generative-language-api',
          api_key: 'some-api-key'
        },
        options: { model: 'gemini-pro', server_sent_events: true }
      )
    end

    it 'allows reading model' do
      expect(real_client.model).to eq('gemini-pro')
    end

    it 'allows writing model' do
      test_address = 'gemini-2.0-flash'
      real_client.model = test_address
      expect(real_client.model).to eq(test_address)
    end
  end
end 