# frozen_string_literal: true

module CsvReports
  class BaseJob < ApplicationJob
    queue_as :low

    private

    def generate_csv(data)
      tempfile = Tempfile.new
      CSV.open(tempfile.path, 'w') do |csv|
        csv << self.class::HEADERS
        data.each { |row| csv << yield(row) }
      end
      tempfile.rewind
      tempfile
    end

    def notify(user_id, file:, filename:, caption:)
      user = User.find user_id
      return unless user.telegram_id

      Telegram::Bot.call(
        'sendDocument',
        form_data: [
          ['document', file, { filename: filename, content_type: 'text/csv' }],
          ['caption', caption],
          ['chat_id', user.telegram_id.to_s],
        ],
      )
    end

    def date_range
      @date_range ||=
        if @from_date && @till_date
          @from_date..@till_date
        elsif @from_date
          @from_date..
        elsif @till_date
          ..@till_date
        end
    end
  end
end
