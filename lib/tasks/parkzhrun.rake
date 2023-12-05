# frozen_string_literal: true

namespace :parkzhrun do
  desc 'create Parkzhrun activity'
  task create_activity: :environment do
    ParkzhrunMailer.success.deliver_later if Parkzhrun::ActivityCreator.call(1.day.ago)
  rescue StandardError => e
    Rollbar.error e
    ParkzhrunMailer.error.deliver_later
  end
end
