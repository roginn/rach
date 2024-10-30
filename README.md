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
client = Rach::Client.new(access_token: YOUR_OPENAI_API_KEY)
response = client.chat("Hello, how are you?")
puts response.content
```

### Conversations

Rach supports stateful conversations with memory:

```ruby
require 'rach'

client = Rach::Client.new(access_token: YOUR_OPENAI_API_KEY)
convo = Rach::Conversation.new
convo.system "You teach the German language."
convo.user "Translate: There are two birds singing outside my window."

response = client.chat(convo)
response.content
# => "Es gibt zwei Vögel, die draußen vor meinem Fenster singen."

convo.add_response(response)

# Continue the conversation...
convo.user "What are the verbs in your translation?"
client.chat(convo)


# Remove the last message from the conversation history and continue
convo.pop
convo.user "Explain the structure of your translation."
client.chat(convo)
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


## License

Rach is available as open source under the terms of the MIT License.
