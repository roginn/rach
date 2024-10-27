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