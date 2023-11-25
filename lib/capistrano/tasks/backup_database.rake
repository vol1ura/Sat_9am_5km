# frozen_string_literal: true

namespace :db do
  desc 'Create and download database backup'
  task :backup do
    on roles(:all) do
      backup_file = "/home/#{fetch(:user)}/db_backups/backup.dump"
      execute "pg_dump -U #{fetch(:user)} -Fc -Z9 #{fetch(:application)} > #{backup_file}"
      download! backup_file, 'tmp/backup.dump'
    end
  end
end
