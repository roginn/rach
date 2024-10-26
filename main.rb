require_relative "lib/rach"
require 'pry'

client = Rach::Client.new
response = client.chat("Hello, how are you?")
puts response.content

class MathStepByStepSchema
  include Rach::ResponseFormat

  def schema
    object do
      array :steps do
        items type: :string
      end
      string :final_answer
    end
  end
end

response = client.chat("2x^2 + 5x - 3 = 0", response_format: MathStepByStepSchema.render(:schema))


puts response.content
