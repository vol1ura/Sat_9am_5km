class Rack::Attack
  # Throttle requests by IP
  #
  # Key: "rack::attack:#{Time.now.to_i/:period}:req/ip:#{req.ip}"
  # Allows 10 requests in 4  seconds
  #        20 requests in 16 seconds
  #        30 requests in 64 seconds
  #        40 requests in ~4 minutes
  (1..4).each do |level|
    throttle('req/ip', limit: 10 * level, period: (4**level).seconds) do |req|
      req.ip if req.path.start_with?('/activities') || req.path.start_with?('/athletes')
    end
  end
end
