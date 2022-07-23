# frozen_string_literal: true

module ApplicationHelper
  def human_result_time(time)
    return 'XX:XX' unless time

    time.strftime(time.hour.zero? ? '%M:%S' : '%H:%M:%S')
  end

  def human_result_pace(time)
    return unless time

    avg_sec = ((((time.hour * 60) + time.min) * 60) + time.sec) / 5
    format '%<min>d:%<sec>02d', min: avg_sec / 60, sec: avg_sec % 60
  end

  def human_activity_name(activity)
    "#{activity.date} - #{activity.event.name}"
  end

  def human_volunteer_role(role)
    I18n.t("activerecord.attributes.volunteer.roles.#{role}")
  end
end
