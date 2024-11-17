module Rach
  class Client
    attr_reader :tracker, :client, :model, :providers

    def initialize(access_token:, model: nil, **kwargs)
      @tracker = UsageTracker.new
      @providers = {}

      if access_token.is_a?(Hash)
        # access_token: { openai: "sk-...", anthropic: "sk-..." }
        setup_providers(access_token)
      else
        raise ArgumentError, "Model must be specified when using single access token" unless model
        @default_model = model

        provider = Provider.for(model)
        setup_providers({ provider.key => access_token })
      end
    end

    def chat(input, **options)
      prompt = input.is_a?(Prompt) ? input : Prompt.new(input, **options)
      model = prompt.model || @default_model

      raise ArgumentError, "No model specified" unless model

      provider_key = Provider.for(model).key
      client = @providers[provider_key]

      request_params = {
        model:,
        messages: prompt.to_messages,
        response_format: prompt.response_format,
        temperature: prompt.temperature,
        tools: prompt.tools&.map(&:function_schema),
        tool_choice: prompt.tools ? "required" : nil,
      }.compact

      response = Response.new(
        client.chat(parameters: request_params),
        request_params
      )

      tracker.track(response)
      response
    end

    private

    def setup_providers(provider_tokens)
      provider_tokens.each do |provider_key, token|
        provider_class = Provider.get_provider_class(provider_key)
        @providers[provider_class.key] = provider_class.new(token)
      end
    end
  end
end
