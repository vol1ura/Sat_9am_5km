# frozen_string_literal: true

class SetFivePlusTrophyDatesJob < ApplicationJob
  queue_as :low

  def perform
    initial_date = Date.current.saturday? ? Date.current : Date.tomorrow.prev_week(:saturday)

    Badge.five_plus_kind.sole.trophies.includes(:athlete).find_each do |trophy|
      res_dates = trophy.athlete.results.published.pluck(:date)
      vol_dates = trophy.athlete.volunteering.unscope(:order).pluck(:date)
      dates = (res_dates | vol_dates).uniq

      5.upto(dates.size) do |k|
        date = initial_date - k.weeks
        next if dates.include?(date) && k != dates.size

        trophy.update!(date: date + 5.weeks) and break
      end
    end
  end
end
