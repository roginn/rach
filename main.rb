require_relative "lib/rach"
require 'pry'
require 'dotenv'

Dotenv.load

access_token = ENV.fetch("OPENAI_ACCESS_TOKEN")

OpenAI.configure do |config|
  config.log_errors = true
end


client = Rach::Client.new(access_token: access_token)
response = client.chat("Hello, how are you?")
puts response.content

# class MathStepByStepSchema
#   include Rach::ResponseFormat

#   def schema
#     object do
#       array :steps do
#         items type: :string
#       end
#       string :final_answer
#     end
#   end
# end

# response = client.chat("2x^2 + 5x - 3 = 0", response_format: MathStepByStepSchema.render(:schema))
# puts response.content

class GermanTranslatorSchema
  include Rach::ResponseFormat

  def explain_structure
    object do
      array :structure_explanation do
        items type: :string
      end
      string :final_translation
    end
  end

  def pos_tagger
    object do
      object :english_sentence do
        array :words do
          items do
            object do
              string :word
              string :part_of_speech
            end
          end
        end
      end
      object :german_sentence do
        array :words do
          items do
            object do
              string :word
              string :part_of_speech
            end
          end
        end
      end
    end
  end
end

# convo = Rach::Conversation.new
# convo.system "You teach the German language."
# convo.user "Translate: There are two birds looking at each other outside my window."

# response = client.chat convo
# puts response.content

# convo.add_response response

# convo.user "Explain the structure of the translation."
# response = client.chat(convo, response_format: GermanTranslatorSchema.render(:explain_structure))
# puts response.content
# convo.add_response response


# convo.user "Tag the parts of speech in the translation."
# response = client.chat(convo, response_format: GermanTranslatorSchema.render(:pos_tagger))
# puts response.content



require_relative "get_weather"

class MakeOrder
  include Rach::Function

  def function_name
    "make_order"
  end

  def function_description
    "Make an order for a product"
  end

  def schema
    object do
      string :product_name
      integer :quantity
    end
  end

  def execute(product_name:, quantity:)
    "Ordering #{quantity} of #{product_name}"
  end
end


tools = [GetWeather, MakeOrder]

# response = client.chat("What is the weather in San Francisco?", tools:)
response = client.chat("I'd like to buy 2 apples.", tools:)


response.on_function(GetWeather) do |fn, args|
  puts "Weather: #{fn.execute(**args)}"
end.on_function(MakeOrder) do |fn, args|
  puts "Order: #{fn.execute(**args)}"
end.on_content do |content|
  puts "Content: #{content}"
end

puts response.content

