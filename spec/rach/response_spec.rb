RSpec.describe Rach::Response do
  let(:raw_response) do
    {
      "id" => "chatcmpl-BXKq9nLR4MzgHmmNx3YjTs8wEFupB",
      "object" => "chat.completion",
      "created" => 1730647695,
      "model" => "gpt-4o-mini-2024-07-18",
      "choices" => [{
        "index" => 0,
        "message" => {
          "role" => "assistant",
          "content" => "Hello, world!"
        },
        "finish_reason" => "stop"
      }],
      "system_fingerprint" => "fp_9d4e2f8ac3",
      "usage" => {
        "prompt_tokens" => 10,
        "completion_tokens" => 20,
        "total_tokens" => 30
      }
    }
  end

  # ... existing tests ...

  describe "#id" do
    it "returns the response id" do
      response = described_class.new(raw_response)
      expect(response.id).to eq("chatcmpl-BXKq9nLR4MzgHmmNx3YjTs8wEFupB")
    end
  end

  describe "#model" do
    it "returns the model name" do
      response = described_class.new(raw_response)
      expect(response.model).to eq("gpt-4o-mini-2024-07-18")
    end
  end

  describe "#created_at" do
    it "returns the creation time as Time object" do
      response = described_class.new(raw_response)
      expect(response.created_at).to eq(Time.at(1730647695))
    end
  end

  describe "#system_fingerprint" do
    it "returns the system fingerprint" do
      response = described_class.new(raw_response)
      expect(response.system_fingerprint).to eq("fp_9d4e2f8ac3")
    end
  end
end
