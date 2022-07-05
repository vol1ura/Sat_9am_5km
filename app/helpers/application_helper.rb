# frozen_string_literal: true

module ApplicationHelper
  def human_result_time(time)
    return 'XX:XX' unless time

    time.strftime(time.hour.zero? ? '%M:%S' : '%H:%M:%S')
  end

  def human_activity_name(activity)
    "#{activity.date} - #{activity.event.name}"
  end

  def human_volunteer_role(role)
    I18n.t("activerecord.attributes.volunteer.roles.#{role}")
  end
end
