# frozen_string_literal: true

namespace :processing do
  desc 'create Parkzhrun activity'
  task parkzhrun: :environment do
    Parkzhrun::ActivityCreator.call(1.day.ago.strftime('%Y-%m-%d'))
  rescue StandardError => e
    Rollbar.error e
    NotificationMailer.parkzhrun_error.deliver_later
  end

  desc 'Compress user images'
  task compress_user_images: :environment do
    User.joins(:image_attachment).find_each do |user|
      Users::ImageCompressor.call(user)
    end
  end
end
