[![Quality&Tests](https://github.com/vol1ura/Sat_9am_5km/actions/workflows/rubyonrails.yml/badge.svg)](https://github.com/vol1ura/Sat_9am_5km/actions/workflows/rubyonrails.yml)
[![Test Coverage](https://api.codeclimate.com/v1/badges/5f0c800f5880bee344af/test_coverage)](https://codeclimate.com/github/vol1ura/Sat_9am_5km/test_coverage)
[![Maintainability](https://api.codeclimate.com/v1/badges/5f0c800f5880bee344af/maintainability)](https://codeclimate.com/github/vol1ura/Sat_9am_5km/maintainability)
[![GPLv3 license](https://img.shields.io/badge/License-GPLv3-blue.svg)](http://perso.crans.org/besson/LICENSE.html)
![Contributions](https://img.shields.io/badge/Contributions-Welcome-brightgreen)

# Sat 9am 5km - run event system

## TODO

- [ ] FEATURE: Up and down athletes in protocol
- [ ] FEATURE: Insert and remove athletes in protocol
- [ ] Top50 results for men and women for each event
- [ ] Separate page with activities inside event
- [x] Remove mini-racer from the project
- [ ] Migrate to Stimulus and Hotwire on frontend
- [ ] CI-CD with GitHub Actions and Capistrano
- [ ] Add Redis and configure adapter for async jobs
- [ ] Add scheduled backups
- [ ] Add logrotate

## Development

To build project install `Docker` and `docker-compose` and execute
```shell
make build_proj
```

Now you can run it
```shell
make proj
```

## Deploy

#### 1. Configure server

```shell
# server
sudo apt update
locale
sudo dpkg-reconfigure locales
adduser <deploy-user>
adduser <deploy-user> sudo
# localhost
ssh-copy-id root@1.2.3.4
ssh-copy-id <deploy-user>@1.2.3.4
```
#### 2. Install rbenv

#### 3. Install postgresql

#### 4. Install nginx

#### 5. Create app dir and copy keys

```shell
scp config/master.key <deploy-user>@1.2.3.4:/home/<deploy-user>/apps/<app-name>/shared/config/master.key
scp ./deploy/.rbenb-vars <deploy-user>@1.2.3.4:/home/<deploy-user>/apps/<app-name>/.rbenv-vars
```

#### 6. Run Capistrano
First time
```shell
cap production puma:config
cap production puma:nginx_config
sudo service nginx restart
cap production puma:systemd:config puma:systemd:enable
```

After push
```shell
cap production deploy
```

#### 7. Install certificate
Instructions on https://certbot.eff.org/instructions?ws=nginx&os=ubuntufocal

Test automatic renewal
```shell
sudo certbot renew --dry-run
```

### 8. Disable ssh login by password
```shell
vim /etc/ssh/sshd_config # set PasswordAuthentication no
systemctl restart ssh
```

### For Heroku

To solve problem with building `mini_racer` on heroku:
```shell
bundle lock --add-platform x86_64-linux
```

After creating application on heroku
```shell
heroku config:set RAILS_MASTER_KEY=$(cat config/master.key)
```

Backup database
```shell
heroku pg:backups:capture --app <app-name>
heroku pg:backups:download --app <app-name>
```

### Database

Restore database
```shell
pg_restore -d <db-name> <path-to-dump> --no-privileges --no-owner -U <user>
```
