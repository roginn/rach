module Rach
  class MessageTemplate
    def initialize(template, role: "user")
      @template = template
      @role = role
    end

    def render(variables = {})
      interpolated = interpolate(@template, variables)
      Message.new(content: interpolated, role: @role)
    end

    private

    def interpolate(text, variables)
      variables.reduce(text) do |result, (key, value)|
        result.gsub(/\{\{#{key}\}\}/, value.to_s)
      end
    end
  end
end
