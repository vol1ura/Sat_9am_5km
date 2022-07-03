# frozen_string_literal: true

module ApplicationHelper
  def human_result_time(time)
    time.strftime(time.hour.zero? ? '%M:%S' : '%H:%M:%S')
  end
end
