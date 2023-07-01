# frozen_string_literal: true

class TimerParser < ApplicationService
  def initialize(activity, timer_file)
    @activity = activity
    @timer_file = timer_file
  end

  def call
    return unless @timer_file
    return if @activity.results.exists?
    raise 'Unknown timer file format' if table.dig(0, 0) != 'STARTOFEVENT'

    @activity.date = Date.parse(table.dig(0, 1)) # Date of event is the second column of first row
    process_table
  end

  private

  def table
    @table ||= CSV.parse(@timer_file.read, headers: false)
  end

  def process_table
    column_correction = 1
    @activity.transaction do
      Result.without_auditing do
        table[1..].each do |row|
          break if row.first == 'ENDOFEVENT'
          column_correction -= 1 and next if row.third.blank? || row.third.include?('00:00:00')

          @activity.results << Result.new(position: row.first.to_i + column_correction, total_time: row.last)
        end
      end
      @activity.save!
    end
  end
end
