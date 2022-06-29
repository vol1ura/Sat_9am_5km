# frozen_string_literal: true

class AddAthleteToResultJob < ApplicationJob
  queue_as :default

  def perform(activity, row)
    athlete = Athlete.find_or_scrape_by_code!(row.first.delete('A').to_i)
    result = activity.results.find_by!(position: row.second.delete('P').to_i)
    result.update!(athlete: athlete)
  end
end
