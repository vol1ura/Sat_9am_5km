# frozen_string_literal: true

class AddAthleteToResultJob < ApplicationJob
  queue_as :default

  discard_on ActiveRecord::RecordInvalid

  def perform(activity_id, code, position)
    activity = Activity.find activity_id
    athlete = Athlete.find_or_scrape_by_code! code.delete('A').to_i

    result = activity.results.find_or_initialize_by position: position.delete('P').to_i
    result = activity.results.new result.as_json(only: %i[total_time position]) if result.athlete_id

    result.without_auditing { result.update! athlete: } unless result.athlete == athlete
  end
end
