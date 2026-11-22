# frozen_string_literal: true

module API
  module Mobile
    class ProfilesController < AuthenticatedController
      def show
        @athlete = current_user.athlete
        @mobile_session = current_mobile_session
        @volunteering_history = volunteering_history(@athlete)
        @scheduled_volunteering = scheduled_volunteering(@athlete)
      end

      private

      def volunteering_history(athlete)
        athlete
          .volunteering
          .where(activity: { date: 5.months.ago.beginning_of_month.. })
          .unscope(:order)
          .group(:role, Arel.sql("date_part('month', date)"))
          .count
          .each_with_object({}) do |(key, count), history|
            history[key.first] ||= Array.new(6, 0)
            history[key.first][5 - ((Date.current.mon - key.last) % 12)] = count
          end
      end

      def scheduled_volunteering(athlete)
        athlete
          .volunteering
          .includes(activity: :event)
          .where(activity: { date: Date.current.. })
          .rewhere(activity: { published: false })
          .reorder(:date)
      end
    end
  end
end
