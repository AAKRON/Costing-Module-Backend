# frozen_string_literal: true

class Rack::Attack
  # Configure Redis for production
  Rack::Attack.cache.store = ActiveSupport::Cache::RedisCacheStore.new

  # Allow all local traffic
  safelist('allow-localhost') do |req|
    '127.0.0.1' == req.ip || '::1' == req.ip
  end

  # Allow an IP address to make 300 requests per 5 minutes (5 reqs/sec)
  throttle('req/ip', limit: 300, period: 5.minutes) do |req|
    req.ip
  end

  # Limit login attempts: 10 attempts per IP per 5 minutes
  throttle('login/ip', limit: 10, period: 5.minutes) do |req|
    if req.path == '/api/v1/sessions' && req.post?
      req.ip
    end
  end

  # Limit login attempts per username
  throttle('login/username', limit: 5, period: 20.minutes) do |req|
    if req.path == '/api/v1/sessions' && req.post?
      # Return the username or IP (for cache key)
      username = req.params['username'].presence
      username&.downcase if username
    end
  end

  # Block suspicious requests
  blocklist('fail2ban pentesters') do |req|
    # Block requests containing known attack patterns
    Rack::Attack::Fail2Ban.filter("pentesters-#{req.ip}", maxretry: 3, findtime: 10.minutes, bantime: 1.hour) do
      CGI.unescape(req.query_string) =~ %r{/etc/passwd} ||
      req.path.include?('/etc/passwd') ||
      req.path.include?('../') ||
      req.path.include?('..\\')
    end
  end

  # Custom response for throttled requests
  self.throttled_responder = lambda do |req|
    retry_after = (req.env['rack.attack.match_data'] || {})[:period]
    [
      429,
      {
        'Content-Type' => 'application/json',
        'Retry-After' => retry_after.to_s
      },
      [{ error: 'Too many requests. Please try again later.' }.to_json]
    ]
  end

  # Custom response for blocklisted requests
  self.blocklisted_responder = lambda do |req|
    [
      403,
      { 'Content-Type' => 'application/json' },
      [{ error: 'Forbidden' }.to_json]
    ]
  end
end