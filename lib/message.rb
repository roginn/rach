module Rach
  class Message
    attr_reader :role, :content

    def initialize(content:, role: "user")
      @content = content
      @role = role
    end

    def to_h
      {
        role: role,
        content: content
      }
    end
  end
end
