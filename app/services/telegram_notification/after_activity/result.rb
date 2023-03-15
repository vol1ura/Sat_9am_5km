# frozen_string_literal: true

module TelegramNotification
  module AfterActivity
    class Result < Base
      private

      def text
        <<~TEXT
          Поздравляем вас с участием в #{activity.number}-м забеге S95 #{activity.event.name}.
          Вы финишировали на #{@entity.position}-м месте в общем зачёте с результатом #{total_time}.
          Общее число принявших участие в забеге спортсменов составило #{activity.results.count}.
          #{super}
        TEXT
      end

      def total_time
        ApplicationController.helpers.human_result_time(@entity.total_time)
      end
    end
  end
end
