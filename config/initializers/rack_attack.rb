class Rack::Attack
  BLACKLIST_IPS = ENV['BLACKLIST_IPS'].to_s.split(',').freeze

  # Throttle requests by IP
  #
  # Key: "rack::attack:#{Time.now.to_i/:period}:req/ip:#{req.ip}"
  [
    [8, 4],
    [16, 15],
    [32, 60],
    [64, 180]
  ].each do |limit, period|
    throttle("req/ip-#{limit}", limit: limit, period: period.seconds) do |req|
      next if req.path.include?('/statistics/')

      req.ip if req.path.start_with?('/activities') || req.path.start_with?('/athletes/') || req.path.start_with?('/user')
    end
  end

  throttle("athletes/ip", limit: 50, period: 30.seconds) do |req|
    req.ip if req.path.match?(%r{^/athletes[^/]})
  end

  throttle("auth_links/ip", limit: 10, period: 1.minute) do |req|
    req.ip if req.path.start_with?('/auth_links/')
  end

  blocklist('pentesters block') do |req|
    path = CGI.unescape(req.path)
    %w[etc/passwd ../../ .php].any? { |pattern| path.include?(pattern) } ||
      req.env['HTTP_ACCEPT'].to_s.include?('../../') ||
      BLACKLIST_IPS.include?(req.ip)
  end
end
