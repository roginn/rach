require 'spec_helper'

RSpec.describe Rach::Provider do
  describe '.for' do
    it 'returns OpenAI provider for GPT models' do
      provider = described_class.for('gpt-4o-mini')
      expect(provider).to eq(Rach::Provider::OpenAI)
    end

    it 'returns OpenAI provider for O1 models' do
      provider = described_class.for('o1-preview')
      expect(provider).to eq(Rach::Provider::OpenAI)
    end

    it 'returns Anthropic provider for Claude models' do
      provider = described_class.for('claude-3.5-sonnet')
      expect(provider).to eq(Rach::Provider::Anthropic)
    end

    it 'raises ArgumentError for unsupported models' do
      expect {
        described_class.for('unsupported-model')
      }.to raise_error(ArgumentError, 'Unsupported model: unsupported-model')
    end
  end

  describe '.create_client' do
    let(:access_token) { 'test-token' }

    it 'creates an OpenAI client' do
      expect(Rach::Provider::OpenAI).to receive(:new).with(access_token)
      described_class.create_client(:openai, access_token)
    end

    it 'creates an Anthropic client' do
      expect(Rach::Provider::Anthropic).to receive(:new).with(access_token)
      described_class.create_client(:anthropic, access_token)
    end

    it 'raises ArgumentError for unknown provider' do
      expect {
        described_class.create_client(:unknown, access_token)
      }.to raise_error(ArgumentError, 'Unknown provider: unknown')
    end
  end

  describe '.get_provider_class' do
    it 'returns OpenAI provider class' do
      provider_class = described_class.get_provider_class(:openai)
      expect(provider_class).to eq(Rach::Provider::OpenAI)
    end

    it 'returns Anthropic provider class' do
      provider_class = described_class.get_provider_class(:anthropic)
      expect(provider_class).to eq(Rach::Provider::Anthropic)
    end

    it 'raises ArgumentError for unknown provider' do
      expect {
        described_class.get_provider_class(:unknown)
      }.to raise_error(ArgumentError, 'Unknown provider: unknown')
    end
  end
end