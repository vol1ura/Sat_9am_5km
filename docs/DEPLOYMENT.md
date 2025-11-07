# Руководство по развертыванию

## Подготовка сервера

### Требования

- Ubuntu Server 20.04+ (рекомендуется)
- Минимум 2GB RAM
- Минимум 20GB свободного места на диске
- Доступ по SSH с правами sudo

### Установка системных зависимостей

```bash
# Обновление системы
sudo apt-get update
sudo apt-get upgrade -y

# Установка базовых зависимостей
sudo apt-get install -y \
  build-essential \
  libssl-dev \
  libreadline-dev \
  zlib1g-dev \
  libyaml-dev \
  libncurses5-dev \
  libffi-dev \
  libgdbm-dev \
  libpq-dev \
  curl \
  git \
  nginx \
  postgresql \
  redis-server \
  imagemagick \
  libvips-dev
```

### Установка Rust (для Ruby YJIT)

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source $HOME/.cargo/env
```

### Установка rbenv

```bash
# Установка rbenv
curl -fsSL https://github.com/rbenv/rbenv-installer/raw/HEAD/bin/rbenv-installer | bash

# Добавление в PATH
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init -)"' >> ~/.bashrc
source ~/.bashrc

# Установка плагина ruby-build
mkdir -p "$(rbenv root)"/plugins
git clone https://github.com/rbenv/ruby-build.git "$(rbenv root)"/plugins/ruby-build
```

### Установка Ruby

```bash
# Установка Ruby 3.4.5
rbenv install 3.4.5
rbenv global 3.4.5

# Проверка версии
ruby -v
```

### Установка Bundler

```bash
gem install bundler --version=2.4.10
```

### Установка PostgreSQL

```bash
# PostgreSQL обычно устанавливается вместе с libpq-dev
# Проверка версии
psql --version

# Создание пользователя и базы данных
sudo -u postgres createuser deploy
sudo -u postgres createdb s95_production -O deploy
```

### Установка Redis

```bash
# Redis обычно устанавливается вместе с redis-server
# Проверка версии
redis-cli --version

# Запуск и автозапуск
sudo systemctl enable redis-server
sudo systemctl start redis-server
```

## Настройка приложения

### Клонирование репозитория

```bash
# Создание директории для приложения
sudo mkdir -p /var/www
sudo chown $USER:$USER /var/www
cd /var/www

# Клонирование репозитория
git clone https://github.com/vol1ura/Sat_9am_5km.git
cd Sat_9am_5km
```

### Настройка переменных окружения

```bash
# Создание файла .env
cp deploy/.env.example deploy/.env

# Редактирование .env
nano deploy/.env
```

Необходимые переменные:
```bash
APP_HOST=s95.ru
RAILS_ENV=production
SECRET_KEY_BASE=<сгенерировать через: rails secret>
DATABASE_URL=postgresql://deploy@localhost/s95_production
REDIS_URL=redis://localhost:6379/0
```

### Настройка базы данных

```bash
# Редактирование config/database.yml
cp config/database.yml.example config/database.yml
nano config/database.yml
```

### Настройка секретов

```bash
# Редактирование credentials
EDITOR=nano rails credentials:edit

# Добавление необходимых секретов:
# mailer:
#   address: smtp.example.com
#   port: 587
#   user_name: your_email@example.com
#   password: your_password
# parkzhrun_api_key: your_api_key
# telegram:
#   bot_token: your_bot_token
```

### Установка зависимостей

```bash
# Установка gems
bundle install --deployment --without development test

# Предкомпиляция assets
RAILS_ENV=production bundle exec rails assets:precompile
```

### Инициализация базы данных

```bash
# Создание базы данных и выполнение миграций
RAILS_ENV=production bundle exec rails db:create
RAILS_ENV=production bundle exec rails db:migrate

# Загрузка начальных данных (если есть)
RAILS_ENV=production bundle exec rails db:seed
```

## Настройка Puma

### Создание systemd сервиса

Создайте файл `/etc/systemd/system/puma.service`:

```ini
[Unit]
Description=Puma HTTP Server
After=network.target

[Service]
Type=notify
User=deploy
WorkingDirectory=/var/www/Sat_9am_5km/current
Environment=RAILS_ENV=production
ExecStart=/home/deploy/.rbenv/shims/bundle exec puma -C config/puma.rb
ExecReload=/bin/kill -USR1 $MAINPID
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

### Создание systemd socket

Создайте файл `/etc/systemd/system/puma.socket`:

```ini
[Unit]
Description=Puma HTTP Server Accept Sockets

[Socket]
ListenStream=0.0.0.0:3000
NoDelay=true
ReusePort=true
Backlog=1024

[Install]
WantedBy=sockets.target
```

### Запуск Puma

```bash
sudo systemctl enable puma.socket
sudo systemctl start puma.socket
sudo systemctl enable puma.service
sudo systemctl start puma.service

# Проверка статуса
sudo systemctl status puma
```

## Настройка Sidekiq

### Создание systemd сервиса

Создайте файл `/etc/systemd/system/sidekiq.service`:

```ini
[Unit]
Description=Sidekiq Background Job Processor
After=syslog.target network.target

[Service]
Type=simple
User=deploy
WorkingDirectory=/var/www/Sat_9am_5km/current
Environment=RAILS_ENV=production
ExecStart=/home/deploy/.rbenv/shims/bundle exec sidekiq -C config/sidekiq.yml
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

### Запуск Sidekiq

```bash
sudo systemctl enable sidekiq
sudo systemctl start sidekiq

# Проверка статуса
sudo systemctl status sidekiq
```

## Настройка Nginx

### Создание конфигурации

Создайте файл `/etc/nginx/sites-available/s95`:

```nginx
upstream puma {
  server unix:///var/www/Sat_9am_5km/shared/tmp/sockets/puma.sock;
}

server {
  listen 80;
  server_name s95.ru www.s95.ru;

  # Редирект на HTTPS (если используется SSL)
  # return 301 https://$server_name$request_uri;

  root /var/www/Sat_9am_5km/current/public;

  access_log /var/www/Sat_9am_5km/shared/log/nginx.access.log;
  error_log /var/www/Sat_9am_5km/shared/log/nginx.error.log;

  client_max_body_size 10M;

  location / {
    try_files $uri @puma;
  }

  location @puma {
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header Host $http_host;
    proxy_redirect off;
    proxy_pass http://puma;
  }

  location ~ ^/(assets|packs)/ {
    expires max;
    gzip_static on;
    add_header Cache-Control public;
  }

  location = /up {
    access_log off;
    return 200 "healthy\n";
    add_header Content-Type text/plain;
  }
}
```

### Активация конфигурации

```bash
sudo ln -s /etc/nginx/sites-available/s95 /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

## Настройка SSL (Let's Encrypt)

```bash
# Установка Certbot
sudo apt-get install -y certbot python3-certbot-nginx

# Получение сертификата
sudo certbot --nginx -d s95.ru -d www.s95.ru

# Автоматическое обновление
sudo certbot renew --dry-run
```

## Настройка Cron (Whenever)

```bash
# Установка whenever
bundle exec whenever --update-crontab

# Проверка crontab
crontab -l
```

## Настройка резервного копирования

### Создание скрипта резервного копирования

Создайте файл `~/db_backups/daily.sh`:

```bash
#!/bin/bash
BACKUP_DIR="$HOME/db_backups"
DATE=$(date +%Y%m%d_%H%M%S)
FILENAME="s95_backup_$DATE.sql"

mkdir -p $BACKUP_DIR
pg_dump -U deploy s95_production > $BACKUP_DIR/$FILENAME
gzip $BACKUP_DIR/$FILENAME

# Удаление старых бэкапов (старше 7 дней)
find $BACKUP_DIR -name "*.sql.gz" -mtime +7 -delete
```

Сделайте скрипт исполняемым:
```bash
chmod +x ~/db_backups/daily.sh
```

## Развертывание с Capistrano

### Настройка Capistrano

Убедитесь, что файл `config/deploy/production.rb` настроен правильно:

```ruby
server 'your-server-ip', user: 'deploy', roles: %w[app db web]

set :deploy_to, '/var/www/Sat_9am_5km'
```

### Первое развертывание

```bash
# На сервере
cap production deploy:check
cap production deploy
```

### Последующие развертывания

```bash
cap production deploy
```

## Мониторинг

### Настройка UptimeRobot

1. Зарегистрируйтесь на [UptimeRobot](https://uptimerobot.com)
2. Добавьте монитор для `https://s95.ru/up`
3. Настройте уведомления

### Настройка Rollbar

1. Зарегистрируйтесь на [Rollbar](https://rollbar.com)
2. Добавьте токен в Rails credentials
3. Настройте уведомления

## Обслуживание

### Просмотр логов

```bash
# Логи приложения
tail -f /var/www/Sat_9am_5km/shared/log/production.log

# Логи Puma
sudo journalctl -u puma -f

# Логи Sidekiq
sudo journalctl -u sidekiq -f

# Логи Nginx
sudo tail -f /var/log/nginx/error.log
```

### Перезапуск сервисов

```bash
# Перезапуск Puma
sudo systemctl restart puma

# Перезапуск Sidekiq
sudo systemctl restart sidekiq

# Перезапуск Nginx
sudo systemctl restart nginx
```

### Обновление приложения

```bash
# На локальной машине
cap production deploy

# Или вручную на сервере
cd /var/www/Sat_9am_5km/current
git pull
bundle install
RAILS_ENV=production bundle exec rails db:migrate
RAILS_ENV=production bundle exec rails assets:precompile
sudo systemctl restart puma
sudo systemctl restart sidekiq
```

### Очистка старых релизов

Capistrano автоматически хранит последние 5 релизов. Для очистки:

```bash
cap production deploy:cleanup
```

## Откат развертывания

```bash
cap production deploy:rollback
```

## Резервное копирование и восстановление

### Резервное копирование базы данных

```bash
pg_dump -U deploy s95_production > backup.sql
```

### Восстановление базы данных

```bash
psql -U deploy s95_production < backup.sql
```

### Резервное копирование файлов

```bash
tar -czf storage_backup.tar.gz /var/www/Sat_9am_5km/shared/storage
```

## Производительность

### Оптимизация PostgreSQL

Настройте `postgresql.conf` для production окружения:
- `shared_buffers`
- `effective_cache_size`
- `maintenance_work_mem`
- `checkpoint_completion_target`

### Оптимизация Puma

Настройте `config/puma.rb`:
- Количество воркеров
- Количество потоков
- Таймауты

### Мониторинг производительности

- Rails Performance: `/app_performance`
- PgHero: `/pg_stats`
- Sidekiq WebUI: `/sidekiq`

