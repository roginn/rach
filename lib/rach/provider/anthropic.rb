require 'securerandom'

module Rach
  module Provider
    class Anthropic < Base

      def initialize(access_token: nil, **kwargs)
        @client = create_client(access_token, **kwargs)
      end

      def chat(**parameters)
        # Extract system message if present
        messages = parameters.dig(:parameters, :messages) || []
        system_message = messages.find { |msg| msg[:role] == "system" }

        # Remove system message from messages array if present
        messages = messages.reject { |msg| msg[:role] == "system" } if system_message

        # Convert messages to Anthropic format
        messages = messages.map do |msg|
          {
            role: msg[:role] == "assistant" ? "assistant" : "user",
            content: msg[:content]
          }
        end

        temperature = (parameters.dig(:parameters, :temperature) || 1).clamp(0, 1)
        max_tokens = parameters.dig(:parameters, :max_tokens) || 1024
        tools = convert_tools(parameters.dig(:parameters, :tools))

        anthropic_params = {
          model: parameters.dig(:parameters, :model),
          messages:,
          temperature:,
          max_tokens:,
          tools:,
          system: system_message&.[](:content)
        }.compact

        puts "Anthropic request params: #{anthropic_params.inspect}" # Debug line

        raw_response = @client.messages(
          parameters: {
            model: anthropic_params[:model],
            messages: anthropic_params[:messages],
            system: anthropic_params[:system],
            temperature: anthropic_params[:temperature],
            max_tokens: anthropic_params[:max_tokens],
            tools: anthropic_params[:tools]
          }.compact
        )

        Response.new(
          id: raw_response["id"],
          model: raw_response["model"],
          content: raw_response.dig("content", 0, "text"),
          tool_calls: convert_tool_calls(raw_response["content"]),
          usage: {
            "prompt_tokens" => raw_response["usage"]["input_tokens"],
            "completion_tokens" => raw_response["usage"]["output_tokens"],
            "total_tokens" => raw_response["usage"]["input_tokens"] + raw_response["usage"]["output_tokens"]
          },
          raw_response: raw_response
        )
      end

      def self.supports?(model)
        model.start_with?("claude")
      end

      private

      def create_client(access_token, **kwargs)
        ::Anthropic::Client.new(
          access_token: access_token,
          **kwargs
        )
      end

      def convert_tools(openai_functions)
        return nil if openai_functions.nil?

        openai_functions.map do |fn|
          {
            name: fn[:function][:name],
            description: fn[:function][:description],
            input_schema: {
              type: "object",
              properties: fn[:function][:parameters][:properties],
              required: fn[:function][:parameters][:required]
            }
          }
        end
      end

      def convert_tool_calls(content)
        return nil if content.nil?

        tool_calls = content.select { |c| c["type"] == "tool_use" }
        return nil if tool_calls.empty?

        tool_calls.map do |call|
          {
            "id" => call["id"],
            "type" => "function",
            "function" => {
              "name" => call["name"],
              "arguments" => call["input"].to_json
            }
          }
        end
      end
    end
  end
end