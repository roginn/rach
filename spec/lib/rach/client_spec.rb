require 'spec_helper'

RSpec.describe Rach::Client do
  let(:tracker) { instance_double(Rach::UsageTracker) }
  
  before do
    allow(Rach::UsageTracker).to receive(:new).and_return(tracker)
    allow(tracker).to receive(:track)
  end

  describe "#chat" do
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
        client = described_class.new(access_token: "fake-token")
        
        expect_any_instance_of(OpenAI::Client).to receive(:chat).with(
          parameters: hash_including(tool_choice: "required")
        )

        client.chat("test prompt", tools: [tool])
      end

      it "sets tool_choice to 'auto' when tools are not present" do
        client = described_class.new(access_token: "fake-token")
        
        expect_any_instance_of(OpenAI::Client).to receive(:chat).with(
          parameters: hash_including(tool_choice: "auto")
        )

        client.chat("test prompt")
      end
    end
  end
end 