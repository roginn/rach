module Rach
  class UsageTracker
    def initialize
      @total_prompt_tokens = 0
      @total_completion_tokens = 0
      @total_tokens = 0
      @total_cached_tokens = 0
      @total_reasoning_tokens = 0
      @request_count = 0
    end

    def track(response)
      return unless response.usage

      @total_prompt_tokens += response.prompt_tokens
      @total_completion_tokens += response.completion_tokens
      @total_tokens += response.total_tokens
      @total_cached_tokens += response.usage.dig("prompt_tokens_details", "cached_tokens") || 0
      @total_reasoning_tokens += response.usage.dig("completion_tokens_details", "reasoning_tokens") || 0
      @request_count += 1
    end

    def stats
      {
        prompt_tokens: @total_prompt_tokens,
        completion_tokens: @total_completion_tokens,
        total_tokens: @total_tokens,
        cached_tokens: @total_cached_tokens,
        reasoning_tokens: @total_reasoning_tokens,
        request_count: @request_count,
        average_tokens_per_request: @request_count > 0 ? (@total_tokens.to_f / @request_count).round(2) : 0
      }
    end
  end
end
