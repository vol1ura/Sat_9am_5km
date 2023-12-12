set :bundle_command, '~/.rbenv/shims/bundle exec'
set :path, File.join(ENV['APP_DEPLOY_PATH'], 'current')
set :output, File.join(ENV['APP_DEPLOY_PATH'], 'shared/log/cron.log')
set :chronic_options, hours24: true

# Example:
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# Learn more: http://github.com/javan/whenever

every 1.day, at: '2' do
  command "$HOME/db_backups/sendmail.sh #{ENV.fetch('ADMIN_EMAIL')}"
end

every :thursday, at: '19' do
  rake 'notification:rage_badges_expiration'
end

every :friday, at: '10' do
  rake 'notification:invite_newbies'
end

every :saturday, at: '18' do
  rake 'notification:breaking_time_badges_expiration'
end

every :saturday, at: '23' do
  command "$HOME/db_backups/weekly.sh #{ENV.fetch('INFO_EMAIL')}"
end

every :sunday, at: '5' do
  rake 'processing:parkzhrun'
end

every :sunday, at: '5:05' do
  rake 'processing:awarding'
  rake 'processing:results'
end

every :sunday, at: '5:15' do
  rake 'processing:home_badge_awarding'
end

every :sunday, at: '5:30' do
  rake 'sitemap:refresh'
end
