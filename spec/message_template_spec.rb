require 'spec_helper'

RSpec.describe Rach::MessageTemplate do
  describe '#render' do
    it 'returns a Message object' do
      template = described_class.new('Hello')
      result = template.render
      expect(result).to be_a(Rach::Message)
    end

    it 'interpolates single variable' do
      template = described_class.new('Hello {{name}}!')
      result = template.render(name: 'World')
      expect(result.content).to eq('Hello World!')
    end

    it 'interpolates multiple variables' do
      template = described_class.new('{{greeting}} {{name}}! How is {{location}}?')
      result = template.render(
        greeting: 'Hi',
        name: 'Alice',
        location: 'London'
      )
      expect(result.content).to eq('Hi Alice! How is London?')
    end

    it 'handles non-string values' do
      template = described_class.new('Count: {{number}}')
      result = template.render(number: 42)
      expect(result.content).to eq('Count: 42')
    end

    it 'leaves unknown variables unchanged' do
      template = described_class.new('Hello {{unknown}}!')
      result = template.render(name: 'World')
      expect(result.content).to eq('Hello {{unknown}}!')
    end

    it 'handles empty variables hash' do
      template = described_class.new('Hello {{name}}!')
      result = template.render
      expect(result.content).to eq('Hello {{name}}!')
    end
  end
end
