module Rach
  class StructuredPrompt
    def initialize(schema)
      @schema = schema
    end

    def build(message, strict: true)
      {
        response_format: {
          type: "json_schema",
          json_schema: {
            name: "structured_response",
            schema: @schema,
          }
        },
        messages: [
          { role: "user", content: message }
        ]
      }
    end
  end
end
