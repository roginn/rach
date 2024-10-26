require_relative "lib/rach"

# Optional: Add convenience method at the root level
def self.chat(message, **options)
  Rach::Client.new.chat(message, **options)
end

client = Rach::Client.new
response = client.chat("Hello, how are you?")
puts response.content

