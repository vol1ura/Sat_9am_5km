# frozen_string_literal: true

class AddAthleteToResultJob < ApplicationJob
  queue_as :default

  discard_on ActiveRecord::RecordInvalid

  def perform(activity_id, code, position)
    activity = Activity.find(activity_id)
    athlete = Athlete.find_or_scrape_by_code!(code.delete('A').to_i)
    result = activity.results.find_or_initialize_by(position: position.delete('P').to_i)
    result.without_auditing do
      result.update!(athlete:)
    end
  end
end
