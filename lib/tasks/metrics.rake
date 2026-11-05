# frozen_string_literal: true

namespace :metrics do
  desc 'Refresh Prometheus metrics snapshot'
  task refresh: :environment do
    snapshot = Metrics::Snapshot.refresh!

    puts "Metrics snapshot refreshed at #{Time.zone.at(snapshot.generated_at)}"
  end
end
