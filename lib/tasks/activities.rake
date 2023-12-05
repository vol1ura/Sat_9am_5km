# frozen_string_literal: true

namespace :activities do
  desc 'Last week processing'
  task processing: :environment do
    Activity.published.where(date: Date.current.all_week).find_each do |activity|
      ResultsProcessingJob.perform_later(activity.id)
    end
  end
end
