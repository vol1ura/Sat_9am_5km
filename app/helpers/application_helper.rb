# frozen_string_literal: true

module ApplicationHelper
  def locale_cache_key(*cache_key_parts)
    [I18n.locale, *cache_key_parts]
  end

  def head_info(tag, text)
    content_for :"meta_#{tag}", text
    text
  end

  def yield_head_info(tag, default_text = '')
    content_for?(:"meta_#{tag}") ? content_for(:"meta_#{tag}") : default_text
  end

  def human_result_time(time)
    return 'xx:xx' if time.blank?

    time_obj =
      case time
      when Numeric
        Time.zone.at(time.round)
      when String
        Time.zone.at(time.to_f.round)
      else
        time
      end

    time_obj.strftime(time_obj.hour.zero? ? '%M:%S' : '%H:%M:%S')
  end

  def time_to_sec(time)
    (((time.hour * 60) + time.min) * 60) + time.sec
  end

  def calculate_time_gap(current_time, reference_time)
    return if current_time.blank? || reference_time.blank?

    gap_sec = Time.zone.parse(current_time).to_i - Time.zone.parse(reference_time).to_i
    return if gap_sec.negative?

    format('+%<min>d:%<sec>02d', min: gap_sec / 60, sec: gap_sec % 60)
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
    I18n.t "activerecord.attributes.volunteer.roles.#{role}"
  end

  def human_contact_type(type)
    I18n.t "activerecord.attributes.contact.contact_types.#{type}"
  end

  def human_phone(phone)
    Phonelib.parse(phone).full_international
  end

  def human_gender(gender)
    I18n.t "activerecord.attributes.athlete.genders.#{gender}" if gender
  end

  def human_badge_kind(kind)
    I18n.t "activerecord.attributes.badge.kinds.#{kind}"
  end

  def sanitized_text(text)
    sanitize text, tags: %w[strong em s blockquote pre ol ul li a p], attributes: %w[href rel target]
  end

  def sanitized_link_to(...)
    sanitize link_to(...), tags: ['a'], attributes: %w[href rel target]
  end

  def event_main_image_tag(event, variant: :full, **)
    image = event.current_image
    image_path = image.attached? ? image.variant(variant) : '/images/event_placeholder.webp'
    image_tag image_path, **
  end

  def athlete_code_id(athlete)
    code = athlete&.code
    return code unless athlete && (athlete.parkrun_code || athlete.fiveverst_code || athlete.runpark_code)

    code_type = Athlete::PersonalCode.new(code).code_type
    url = format Athletes::FindNameService::NAME_PATH.dig(code_type, :url), athlete.public_send(code_type)
    external_link_to code, url
  end

  def telegram_link(user)
    return unless user&.telegram_user

    external_link_to "@#{user.telegram_user}", "https://t.me/#{user.telegram_user}"
  end

  def external_link_to(title = nil, options = nil, html_options = {}, &)
    target_options = { target: '_blank', rel: 'noopener' }
    if block_given?
      link_to title, (options || {}).merge(target_options), &
    else
      link_to title, options, **html_options, **target_options
    end
  end

  def user_image_path(user)
    user&.image&.attached? ? user.image.variant(:web) : '/images/person.jpg'
  end
end
