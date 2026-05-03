class Rack::Attack
  # Use Redis if available for production, otherwise memory store
  # Rails.cache is used by default

  # Throttle login attempts per IP
  throttle('login/ip', limit: 5, period: 60.seconds) do |req|
    req.ip if req.path == '/login' && req.post?
  end

  # Throttle login attempts per email
  throttle('login/email', limit: 5, period: 60.seconds) do |req|
    if req.path == '/login' && req.post?
      # Normalize email parameter
      req.params['email'].to_s.downcase.gsub(/\s+/, '').presence
    end
  end

  # Throttle all requests from a single IP
  throttle('req/ip', limit: 300, period: 5.minutes) do |req|
    req.ip unless req.path.start_with?('/assets/')
  end

  # Block suspicious user agents
  blocklist('block suspicious agents') do |req|
    req.user_agent =~ /sqlmap|nikto|nmap|masscan/i
  end

  # Custom response for throttled requests
  self.throttled_responder = lambda do |env|
    retry_after = (env['rack.attack.match_data'] || {})[:period]
    [
      429,
      {
        'Content-Type' => 'text/plain',
        'Retry-After' => retry_after.to_s
      },
      ["Muitas requisições. Por favor, tente novamente mais tarde."]
    ]
  end
end
