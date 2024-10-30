require_relative "lib/rach"
require 'pry'
require 'dotenv'

Dotenv.load

client = Rach::Client.new
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

binding.pry
response = client.chat("What is the weather in San Francisco?", functions: [GetWeather.function_schema])
