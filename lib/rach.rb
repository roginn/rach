require 'openai'
require 'anthropic'

require_relative "rach/version"
require_relative "rach/client"
require_relative "rach/errors"
require_relative "rach/response"
require_relative "rach/message"
require_relative "rach/message_template"
require_relative "rach/response_format"
require_relative "rach/conversation"
require_relative "rach/usage_tracker"
require_relative "rach/function"
require_relative "rach/provider/base"
require_relative "rach/provider/openai"
require_relative "rach/provider/anthropic"
require_relative "rach/provider/google"
require_relative "rach/provider"
require_relative "rach/prompt"

module Rach
  # Your code goes here...
end
