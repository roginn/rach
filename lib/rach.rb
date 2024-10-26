require 'openai'
require 'dotenv'

Dotenv.load

require_relative "rach/version"
require_relative "client"
require_relative "errors"
require_relative "response"
require_relative "message"
require_relative "message_template"


OpenAI.configure do |config|
  config.access_token = ENV.fetch("OPENAI_ACCESS_TOKEN")
  # config.log_errors = true # Highly recommended in development, so you can see what errors OpenAI is returning. Not recommended in production because it could leak private data to your logs.
end

module Rach
  # Your code goes here...
end
