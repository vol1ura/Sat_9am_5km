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

  def human_result_pace(time, distance = 5)
    return unless time

    avg_sec = (((((time.hour * 60) + time.min) * 60) + time.sec) / distance.to_f).round
    format '%<min>d:%<sec>02d', min: avg_sec / 60, sec: avg_sec % 60
  end

  def human_activity_name(activity)
    "#{activity.date} - #{activity.event.name}"
  end

  def human_volunteer_role(role)
    I18n.t("activerecord.attributes.volunteer.roles.#{role}")
  end

  def sanitized_text(text)
    sanitize text, tags: %w[strong em s blockquote pre ol ul li a p], attributes: %w[href rel target]
  end

  def event_main_image_tag(event, options = {})
    image_tag event.main_picture_link || 'events/placeholder_big.jpg', **options
  end

  def svg_icon_tag(icon, size = '48px')
    svg_title_mapping = {
      calendar: 'Дата',
      first_man: 'Первый мужчина',
      first_woman: 'Первая женщина',
      park: 'Мероприятие',
      participants: 'Количество участников',
      volunteers: 'Количество волонтёров',
      watch: 'Результат'
    }
    title = svg_title_mapping[icon]
    image_tag "svg/#{icon}.svg", width: size, title: title, alt: title
  end

  def athlete_external_link(athlete)
    return unless athlete && (athlete.parkrun_code || athlete.fiveverst_code)
    return if athlete.fiveverst_code.to_i > Athlete::RUN_PARK_BORDER

    code_type = Athlete::PersonalCode.new(athlete.code).code_type
    url = format(AthleteFinder::NAME_PATH.dig(code_type, :url), athlete.public_send(code_type))
    link_to 'открыть', url, target: '_blank', rel: 'noopener'
  end
end
