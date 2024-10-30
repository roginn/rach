module Rach
  class Conversation
    def initialize
      @messages = []
    end

    def add_message(message)
      raise ArgumentError, "Expected Message object" unless message.is_a?(Message)
      @messages << message
      self
    end

    def add_response(response)
      assistant(response.content)
    end

    def add(content, role: "user")
      add_message(Message.new(content: content, role: role))
    end

    def system(content)
      add(content, role: "system")
      self
    end

    def user(content)
      add(content, role: "user")
      self
    end

    def assistant(content)
      add(content, role: "assistant")
      self
    end

    def to_a
      @messages.map(&:to_h)
    end

    def clear
      @messages.clear
    end

    def empty?
      @messages.empty?
    end

    def pop
      @messages.pop
    end
  end
end
