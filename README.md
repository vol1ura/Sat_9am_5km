[![Quality&Tests](https://github.com/vol1ura/Sat_9am_5km/actions/workflows/rubyonrails.yml/badge.svg)](https://github.com/vol1ura/Sat_9am_5km/actions/workflows/rubyonrails.yml)
[![CodeQL](https://github.com/vol1ura/Sat_9am_5km/actions/workflows/codeql.yml/badge.svg)](https://github.com/vol1ura/Sat_9am_5km/actions/workflows/codeql.yml)
[![Code Coverage](https://qlty.sh/gh/vol1ura/projects/Sat_9am_5km/coverage.svg)](https://qlty.sh/gh/vol1ura/projects/Sat_9am_5km)
[![Maintainability](https://qlty.sh/gh/vol1ura/projects/Sat_9am_5km/maintainability.svg)](https://qlty.sh/gh/vol1ura/projects/Sat_9am_5km)

[![GPLv3 license](https://img.shields.io/badge/License-GPLv3-blue.svg)](http://perso.crans.org/besson/LICENSE.html)
![Contributions](https://img.shields.io/badge/Contributions-Welcome-brightgreen)
![Website](https://img.shields.io/website?down_color=red&down_message=failed&up_color=blue&up_message=online&url=https%3A%2F%2Fs95.ru)

# Sat 9am 5km - run events system

> 📖 **Документация на русском языке**: [README_RU.md](README_RU.md) | [API](docs/API.md) | [Архитектура](docs/ARCHITECTURE.md) | [Развертывание](docs/DEPLOYMENT.md)

## Maintenance

Reset Postgres stats with:

```sql
SELECT pg_stat_statements_reset();
```

## Development

Create `deploy/.env` and `config/database.yml` files:
```shell
cp ./deploy/.env.example ./deploy/.env
cp ./config/database.yml.example ./config/database.yml
```

To build project install `Docker` and execute
```shell
make build
make ash
# in docker container
rails db:prepare
rake db:parse_parkrun_codes[kuzminki_db.csv]
rails db:environment:set RAILS_ENV=test
# add secrets
rails credentials:edit --environment test
# run tests
rspec
```

Now you can run it

```shell
make
```

- Site [http://localhost:3000](http://localhost:3000)
- Admin panel [http://localhost:3000/admin](http://localhost:3000/admin)
- Email previews [http://localhost:3000/rails/mailers](http://localhost:3000/rails/mailers)
- Database panel [http://localhost:3003](http://localhost:3003/?pgsql=db&username=postgres)
- Bug tracker [Rollbar.com](https://app.rollbar.com/a/Urka/fix/items)
- Sidekiq [WebUI](https://s95.ru/sidekiq) for admin users
- Rails Performance [dev](http://localhost:3000/app_performance/) or [prod](https://s95.ru/app_performance/) for admin users
- Postgres Performance [dev](http://localhost:3000/pg_stats) or [prod](https://s95.ru/pg_stats)
- Active Storage Dashboard [dev](http://localhost:3000/storage) or [prod](https://s95.ru/storage)
- Uptime monitor [UptimeRobot](https://dashboard.uptimerobot.com/monitors/797544445)

## Server setup

To install web application on Ubuntu server run

1. Install dependencies:
```
sudo apt-get install -y libyaml-dev
```

2. Install Rust to build Ruby with YJIT on the next step
```
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

3. Install or update `rbenv` using [rbenv-installer](https://github.com/rbenv/rbenv-installer#rbenv-installer):

4. Then install Ruby
```
rbenv install 3.4.5
rbenv global 3.4.5
```
