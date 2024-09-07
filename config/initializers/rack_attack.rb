class Rack::Attack
  # Throttle requests by IP
  #
  # Key: "rack::attack:#{Time.now.to_i/:period}:req/ip:#{req.ip}"
  # Allows 10 requests in 9   seconds
  #        20 requests in 27  seconds
  #        30 requests in 81  seconds
  #        40 requests in 243 seconds
  (2..5).each do |level|
    throttle("req/ip-#{level}", limit: 10 * (level - 1), period: (3**level).seconds) do |req|
      req.ip if req.path.start_with?('/activities') || req.path.start_with?('/athletes/') || req.path.start_with?('/user')
    end
  end

  throttle("athletes/ip", limit: 50, period: 30.seconds) do |req|
    req.ip if req.path.match?(%r{^/athletes[^/]})
  end

  blocklist('pentesters block') do |req|
    %w[etc/passwd ../../].include?(CGI.unescape(req.path)) ||
      req.path.end_with?('.php') ||
      req.env['HTTP_ACCEPT'].to_s.include?('../../')
  end
end
