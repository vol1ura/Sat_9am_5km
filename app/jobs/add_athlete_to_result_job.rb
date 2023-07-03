# frozen_string_literal: true

class AddAthleteToResultJob < ApplicationJob
  queue_as :default

  discard_on ActiveRecord::RecordInvalid

  def perform(activity, row)
    athlete = Athlete.find_or_scrape_by_code!(row.first.delete('A').to_i)
    result = activity.results.find_or_initialize_by(position: row.second.delete('P').to_i)
    result.without_auditing do
      result.update!(athlete: athlete)
    end
  end
end
