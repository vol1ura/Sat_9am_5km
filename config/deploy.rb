# config valid for current version and patch releases of Capistrano
lock '~> 3.17.0'

set :user, ENV['DEPLOY_USER']
set :rbenv_type, :user
set :rbenv_ruby, '3.1.0'

set :application, ENV['APP_NAME']
set :repo_url, ENV['APP_REPO']

set :branch, 'master'
set :deploy_to, ENV['APP_DEPLOY_PATH']

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
append :linked_files, 'config/master.key'

# Default value for linked_dirs is []
append :linked_dirs, 'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets' # , 'public/system', 'tmp/webpacker', 'public/system', 'vendor/javascript', 'storage'

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure

set :sidekiq_service_unit_name, 'sidekiq'
set :sidekiq_service_unit_user, :system
set :sidekiq_config, 'config/sidekiq.yml'
set :sidekiq_default_hooks, false

after 'deploy:starting', 'sidekiq:quiet'
after 'deploy:started', 'sidekiq:stop'
after 'deploy:published', 'sidekiq:start'
