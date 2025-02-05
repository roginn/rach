module Rach
  module Provider

    AVAILABLE_PROVIDERS = [
      Provider::OpenAI,
      Provider::Anthropic,
      Provider::Google
    ].to_h { |p| [p.key, p] }.freeze

    def self.for(model)
      _key, provider_class = AVAILABLE_PROVIDERS.find { |_, p| p.supports?(model) }
      raise ArgumentError, "Unsupported model: #{model}" unless provider_class

      provider_class
    end

    def self.create_client(provider_key, access_token)
      provider_class = get_provider_class(provider_key)
      provider_class.new(access_token:)
    end

    def self.get_provider_class(key)
      provider_class = AVAILABLE_PROVIDERS[key.to_sym]
      raise ArgumentError, "Unknown provider: #{key}" unless provider_class
      provider_class
    end
  end
end