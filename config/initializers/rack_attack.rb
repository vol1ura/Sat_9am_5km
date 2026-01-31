class Rack::Attack
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

      req.ip if req.path.start_with?('/activities') || req.path.start_with?('/athletes/') ||
        req.path.start_with?('/user') || req.path == '/pages/submit_feedback'
    end
  end

  throttle('athletes/ip', limit: 50, period: 30.seconds) do |req|
    req.ip if req.path.match?(%r{^/athletes[^/]})
  end

  throttle('auth_links/ip', limit: 10, period: 1.minute) do |req|
    req.ip if req.path.start_with?('/auth_links/')
  end

  blocklist('scrapers') do |req|
    next false unless req.path.match?(%r{\A/(activities|athletes)/\d+})

    Allow2Ban.filter("scraper:#{req.ip}", maxretry: 160, findtime: 15.minutes, bantime: 1.week) do
      !req.path.match?(%r{/(best_result|statistics|duels)})
    end
  end

  blocklist('pentesters') do |req|
    ban_key = "rack_attack:pentesters:ban:#{req.ip}"
    next true if Rails.cache.read(ban_key)

    if req.env['HTTP_ACCEPT'].to_s.include?('../../')
      Rails.cache.write(ban_key, true, expires_in: 2.days)
    else
      false
    end
  end
end

ActiveSupport::Notifications.subscribe(/rack_attack/) do |_name, _start, _finish, _request_id, payload|
  req = payload[:request]

  Rollbar.warning(
    'Rack::Attack triggered',
    ip: req.ip,
    path: req.path,
    type: req.env['rack.attack.match_type'],
    matched: req.env['rack.attack.matched'],
    user_agent: req.user_agent
  )
end
