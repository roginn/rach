require 'openai'
require 'dotenv'

Dotenv.load

require_relative "rach/version"
require_relative "rach/client"
require_relative "rach/errors"
require_relative "rach/response"
require_relative "rach/message"
require_relative "rach/message_template"
require_relative "rach/response_format"

OpenAI.configure do |config|
  config.access_token = ENV.fetch("OPENAI_ACCESS_TOKEN")
  # config.log_errors = true # Highly recommended in development, so you can see what errors OpenAI is returning. Not recommended in production because it could leak private data to your logs.
end

module Rach
  # Your code goes here...
end
