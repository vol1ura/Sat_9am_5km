# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

set :path, File.join(ENV['APP_DEPLOY_PATH'], 'current')
set :output, -> { '2>&1 | logger -t whenever_cron' }
set :chronic_options, hours24: true

# Example:
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

every 1.day, at: '2' do
  command "$HOME/db_backups/sendmail.sh #{ENV['ADMIN_EMAIL']}"
end

every :thursday, at: '19' do
  rake 'badges:notify_rage_badges_expiration'
end

every :saturday, at: '19' do
  rake 'badges:notify_breaking_time_badges_expiration'
end

every :saturday, at: '23' do
  command "$HOME/db_backups/weekly.sh #{ENV['INFO_EMAIL']}"
end

every :sunday, at: '5' do
  rake 'parkzhrun:create_activity'
end

every :sunday, at: '5:10' do
  rake 'badges:weekly_awarding'
  rake 'activities:processing'
end

every :sunday, at: '5:20' do
  rake 'sitemap:refresh'
end
