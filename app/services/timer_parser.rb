# frozen_string_literal: true

class TimerParser < ApplicationService
  class FormatError < StandardError; end

  def initialize(activity, timer_file)
    @activity = activity
    @timer_file = timer_file
  end

  def call
    return unless @timer_file
    raise FormatError, table.first.inspect if table.dig(0, 0) != 'STARTOFEVENT'

    @activity.update! date: Date.parse(table.dig(0, 1)) # Date of event is the second column of first row
    TimerProcessingJob.perform_later @activity.id, timer_data
  end

  private

  def table
    @table ||= CSV.parse @timer_file.read, headers: false
  end

  def timer_data
    position_correction = 1
    table[1..].each_with_object([]) do |row, data|
      break data if row.first == 'ENDOFEVENT'

      if row.third.blank? || row.third.include?('00:00:00')
        position_correction -= 1
        next
      end
      raise FormatError, row.inspect unless row.third&.match?(/\d+/) && row.third.match?(/\d\d:\d\d:\d\d/)

      data << { position: row.first.to_i + position_correction, total_time: row.third.strip }
    end
  end
end
