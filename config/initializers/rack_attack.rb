class Rack::Attack
  # Throttle requests by IP
  #
  # Key: "rack::attack:#{Time.now.to_i/:period}:req/ip:#{req.ip}"
  # Allows 10 requests in 3  seconds
  #        20 requests in 9  seconds
  #        30 requests in 27 seconds
  #        40 requests in 81 seconds
  (1..4).each do |level|
    throttle('req/ip', limit: 10 * level, period: (3**level).seconds) do |req|
      req.ip if req.path.start_with?('/activities') || req.path.start_with?('/athletes') || req.path.start_with?('/user')
    end
  end

  blocklist('pentesters block') do |req|
    %w[etc/passwd ../../].include?(CGI.unescape(req.path)) || req.path.end_with?('.php') ||
    req.env['HTTP_ACCEPT'].to_s.include?('../../')
  end
end
