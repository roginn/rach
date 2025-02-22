# Rach

A lightweight Ruby framework for OpenAI interactions, focusing on simplicity and clean design.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rach'
```

And then execute:
```bash
$ bundle install
```

Or install it yourself as:
```bash
$ gem install rach
```

## Usage

### Basic Chat

```ruby
require 'rach'
client = Rach::Client.new(access_token: YOUR_OPENAI_API_KEY, model: "gpt-4o")
response = client.chat("Hello, how are you?")
puts response.content
# => "Hello! I'm just a computer program, so I don't have feelings, but I'm here and ready to help you. How can I assist you today?"
```

### Conversations

Rach supports stateful conversations with memory:

```ruby
require 'rach'

client = Rach::Client.new(access_token: YOUR_OPENAI_API_KEY, model: "gpt-4o")
convo = Rach::Conversation.new

convo.system "You are a helpful historian."

# 1. First user question
convo.user "When was the Statue of Liberty dedicated? Provide only the year."
response = client.chat(convo)
puts response.content
# => "1886"

# 2. Add the response to the conversation
convo.add_response(response)

# 3. Continue the conversation (the answer references the original fact: 1886)
convo.user "Name a major city that was incorporated in that year"
response = client.chat(convo)
puts response.content
# => "Vancouver"

# 4. Remove the most recent user message ("Name a major city...")
convo.pop

# 5. Ask a new question that references the Statue of Liberty, not Vancouver
convo.user "Why was it built?"
response = client.chat(convo)
puts response.content
# => "The Statue of Liberty was built to commemorate the 100th anniversary of the signing of the Declaration of Independence."
```

### Response Formatting

Define structured response schemas for type-safe AI responses:

```ruby
class GermanTranslatorSchema
  include Rach::ResponseFormat

  def explain_structure
    object do
      array :structure_explanation do
        items type: :string
        description "A step by step explanation of the structure of the translation."
      end
      string :final_translation
    end
  end
end

response = client.chat(convo, response_format: GermanTranslatorSchema.render(:explain_structure))
JSON.load(response.content)
# => {"structure_explanation"=> ["The phrase starts with 'Es gibt' which translates to 'There are'. 'Es' is a pronoun that means 'it', and 'gibt' is the third person singular form of the verb 'geben' (to give), meaning 'there are' in this context.", "'zwei Vögel' means 'two birds'. 'zwei' is the number 'two' and 'Vögel' is the plural form of 'Vogel' (bird).", "The relative clause 'die draußen vor meinem Fenster singen' describes the birds. 'die' is a relative pronoun meaning 'that' or 'which',' 'draußen' means 'outside', and 'vor meinem Fenster' means 'in front of my window'.", "'singen' is the infinitive form of the verb 'sing' (to sing). It tells us what the birds are doing."], "final_translation"=>"Es gibt zwei Vögel, die draußen vor meinem Fenster singen."}
```

### Function Calling / Tools

Rach supports OpenAI's function calling feature:

```ruby
class GetWeather
  include Rach::Function

  def function_name
    "get_current_weather"
  end

  def function_description
    "Get the current weather in a given location"
  end

  def schema
    object do
      string :location, description: "The city and state, e.g. San Francisco, CA"
      string :unit, enum: %w[celsius fahrenheit]
    end
  end

  def execute(location:, unit: "fahrenheit")
    # Implementation of weather fetching logic
    "The weather in #{location} is nice 🌞 #{unit}"
  end
end

response = client.chat("What is the weather in San Francisco?", tools: [GetWeather.function_schema])
response.tool_calls
# => [{"id"=>"call_8v3MuUICwn0AjPRy1wZMCXtf",
#   "type"=>"function",
#   "function"=>{"name"=>"get_current_weather", "arguments"=>"{\"location\":\"San Francisco, CA\",\"unit\":\"celsius\"}"}}]
```

### Multiple Providers

Rach supports using multiple providers in your application. You can configure different providers and their parameters when creating a client:

```ruby
client = Rach::Client.new(
  providers: {
    openai: {
      access_token: YOUR_OPENAI_API_KEY
    },
    anthropic: {
      access_token: YOUR_ANTHROPIC_API_KEY
    }
  }
)

# Use specific provider
response = client.chat("Hello!", model: "gpt-4o")
puts response.content

# Switch to another provider
response = client.chat("Hi there!", model: "claude-3-5-sonnet-20241022")
puts response.content
```

Rach uses the gems `ruby-openai` and `anthropic` to make API calls to each provider. You can configure the providers separately in the `providers` hash, and they will be used in the respective clients:

```ruby
client = Rach::Client.new(
  providers: {
    openai: {
      access_token: YOUR_OPENAI_API_KEY,
      uri_base: "https://oai.hconeai.com/",
       extra_headers: {
        "X-Proxy-TTL" => "43200",
        "X-Proxy-Refresh": "true",
        "Helicone-Auth": "Bearer HELICONE_API_KEY",
        "helicone-stream-force-format" => "true",
      }
    },
    anthropic: {
      access_token: YOUR_ANTHROPIC_API_KEY,
      request_timeout: 240
    }
  }
)
```

### Logging

Rach supports logging of API calls and their parameters. You can provide any logger that responds to the `info` method:

```ruby
require 'logger'

# Create a logger that writes to STDOUT
logger = Logger.new(STDOUT)

# Pass the logger when creating the client
client = Rach::Client.new(
  access_token: YOUR_OPENAI_API_KEY,
  model: "gpt-4",
  logger: logger
)

# Now when you make API calls, parameters will be logged
client.chat("Hello!")
# [2024-01-20T10:30:00.000Z] INFO: Making API call to openai
# [2024-01-20T10:30:00.000Z] INFO: Request parameters: {:model=>"gpt-4", :messages=>[{:role=>"user", :content=>"Hello!"}], :temperature=>1.0}
```

You can also use your own custom logger as long as it responds to the `info` method:

```ruby
class CustomLogger
  def info(message)
    puts "[RACH] #{message}"
  end
end

client = Rach::Client.new(
  access_token: YOUR_OPENAI_API_KEY,
  model: "gpt-4",
  logger: CustomLogger.new
)
```

## License

Rach is available as open source under the terms of the MIT License.
