# frozen_string_literal: true

module ApplicationHelper
  def head_info(tag, text)
    content_for :"meta_#{tag}", text
  end

  def yield_head_info(tag, default_text = '')
    content_for?(:"meta_#{tag}") ? content_for(:"meta_#{tag}") : default_text
  end

  def human_result_time(time)
    return 'xx:xx' unless time

    time.strftime(time.hour.zero? ? '%M:%S' : '%H:%M:%S')
  end

  def time_to_sec(time)
    (((time.hour * 60) + time.min) * 60) + time.sec
  end

  def human_result_pace(time, distance = 5)
    return unless time

    avg_sec = (time_to_sec(time) / distance.to_f).round
    format '%<min>d:%<sec>02d', min: avg_sec / 60, sec: avg_sec % 60
  end

  def human_activity_name(activity)
    "#{l activity.date} - #{activity.event_name}"
  end

  def human_volunteer_role(role)
    I18n.t("activerecord.attributes.volunteer.roles.#{role}")
  end

  def kind_of_badge(badge)
    I18n.t("activerecord.attributes.badge.kinds.#{badge.kind}")
  end

  def sanitized_text(text)
    sanitize text, tags: %w[strong em s blockquote pre ol ul li a p], attributes: %w[href rel target]
  end

  def sanitized_link_to(...)
    sanitize link_to(...), tags: ['a'], attributes: %w[href rel target]
  end

  def event_main_image_tag(event, options = {})
    image_tag event.main_picture_link || 'events/placeholder_big.jpg', **options
  end

  def athlete_code_id(athlete)
    code = athlete&.code
    return code unless athlete && (athlete.parkrun_code || athlete.fiveverst_code || athlete.runpark_code)

    code_type = Athlete::PersonalCode.new(code).code_type
    url = format(Athletes::Finder::NAME_PATH.dig(code_type, :url), athlete.public_send(code_type))
    external_link_to code, url
  end

  def telegram_link(user)
    return unless user&.telegram_user

    external_link_to "@#{user.telegram_user}", "https://t.me/#{user.telegram_user}"
  end

  def external_link_to(title = nil, options = nil, html_options = {}, &)
    link_to title, *[options, html_options.merge(target: '_blank', rel: 'noopener')].compact, &
  end

  def user_image_url(user)
    user&.image&.attached? ? user.image.variant(:web) : 'person.jpg'
  end
end
