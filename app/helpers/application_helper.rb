# frozen_string_literal: true

module ApplicationHelper
  def human_result_time(time)
    time.strftime(time < 1.hour ? '%M:%S' : '%H:%M:%S')
  end
end
