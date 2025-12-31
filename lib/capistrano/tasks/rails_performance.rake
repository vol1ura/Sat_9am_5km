# frozen_string_literal: true

namespace :rails_performance do
  desc 'Create deploy event in RailsPerformance metrics'
  task :deploy_event do
    on roles(:app) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :bundle, :exec, :rails, 'runner', %q('RailsPerformance.create_event(name: "Deploy")')
        end
      end
    end
  end
end
