module Rach
  class Client
    attr_reader :tracker, :client, :model, :providers
    attr_accessor :logger

    def initialize(providers: nil, access_token: nil, model: nil, logger: nil, **kwargs)
      @tracker = UsageTracker.new
      @providers = {}
      @logger = logger

      if providers
        setup_providers(providers)
      elsif access_token && model
        @default_model = model
        provider = Provider.for(model)
        setup_providers({ provider.key => { access_token: access_token } })
      else
        raise ArgumentError, "Either (providers) or (access_token AND model) must be provided"
      end
    end

    def chat(input, **options)
      prompt = input.is_a?(Prompt) ? input : Prompt.new(input, **options)
      model = prompt.model || @default_model

      raise ArgumentError, "No model specified" unless model

      provider_key = Provider.for(model).key
      client = @providers[provider_key]

      # Filter out options that are already handled by Prompt
      filtered_options = options.reject { |k, _| [:model, :temperature, :response_format, :tools].include?(k) }

      request_params = {
        model:,
        messages: prompt.to_messages,
        response_format: prompt.response_format,
        temperature: prompt.temperature,
        tools: prompt.tools&.map(&:function_schema),
        **filtered_options  # Pass through remaining options to the underlying client
      }.compact


      response = client.chat(parameters: request_params)
      tracker.track(response)
      response
    end

    private

    def setup_providers(provider_configs)
      provider_configs.each do |provider_key, config|
        provider_class = Provider.get_provider_class(provider_key)
        @providers[provider_class.key] = provider_class.new(logger: @logger, **config)
      end
    end
  end
end
