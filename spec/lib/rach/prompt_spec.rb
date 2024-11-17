require 'spec_helper'

RSpec.describe Rach::Prompt do
  describe '#initialize' do
    it 'accepts a string content' do
      prompt = described_class.new("Hello")
      expect(prompt.content).to eq("Hello")
    end

    it 'accepts a Message object' do
      message = Rach::Message.new(content: "Hello", role: "user")
      prompt = described_class.new(message)
      expect(prompt.content).to eq(message)
    end

    it 'accepts a Conversation object' do
      convo = Rach::Conversation.new
      convo.user("Hello")
      prompt = described_class.new(convo)
      expect(prompt.content).to eq(convo)
    end

    it 'accepts optional configuration' do
      prompt = described_class.new("Hello",
        model: "claude-3-sonnet",
        temperature: 0.7,
        response_format: { type: "json" },
        tools: [double("Tool")]
      )

      expect(prompt.model).to eq("claude-3-sonnet")
      expect(prompt.temperature).to eq(0.7)
      expect(prompt.response_format).to eq({ type: "json" })
      expect(prompt.tools).to be_an(Array)
    end
  end

  describe '#to_messages' do
    it 'converts string to messages array' do
      prompt = described_class.new("Hello")
      expect(prompt.to_messages).to eq([{ role: "user", content: "Hello" }])
    end

    it 'converts Message to messages array' do
      message = Rach::Message.new(content: "Hello", role: "system")
      prompt = described_class.new(message)
      expect(prompt.to_messages).to eq([{ role: "system", content: "Hello" }])
    end

    it 'converts Conversation to messages array' do
      convo = Rach::Conversation.new
      convo.system("I am a bot")
      convo.user("Hello")
      prompt = described_class.new(convo)
      expect(prompt.to_messages).to eq([
        { role: "system", content: "I am a bot" },
        { role: "user", content: "Hello" }
      ])
    end

    it 'raises ArgumentError for invalid content type' do
      expect {
        described_class.new(123).to_messages
      }.to raise_error(ArgumentError, "content must be a String, Message, or Conversation")
    end
  end
end