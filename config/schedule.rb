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

every :friday, at: '1' do
  rake 'pghero:clean_query_stats'
end

every :friday, at: '10' do
  rake 'notification:invite_newbies'
end

every :sunday, at: '5' do
  rake 'processing:parkzhrun'
end

every :sunday, at: '5:30' do
  rake 'sitemap:create'
end

every :sunday, at: '12' do
  rake 'notification:doubled_results'
end

every :sunday, at: '12:05' do
  rake 'notification:incorrect_activities'
end
