[![Quality&Tests](https://github.com/vol1ura/Sat_9am_5km/actions/workflows/rubyonrails.yml/badge.svg)](https://github.com/vol1ura/Sat_9am_5km/actions/workflows/rubyonrails.yml)
[![CodeQL](https://github.com/vol1ura/Sat_9am_5km/actions/workflows/codeql.yml/badge.svg)](https://github.com/vol1ura/Sat_9am_5km/actions/workflows/codeql.yml)
[![Test Coverage](https://api.codeclimate.com/v1/badges/5f0c800f5880bee344af/test_coverage)](https://codeclimate.com/github/vol1ura/Sat_9am_5km/test_coverage)
[![Maintainability](https://api.codeclimate.com/v1/badges/5f0c800f5880bee344af/maintainability)](https://codeclimate.com/github/vol1ura/Sat_9am_5km/maintainability)

[![GPLv3 license](https://img.shields.io/badge/License-GPLv3-blue.svg)](http://perso.crans.org/besson/LICENSE.html)
![Contributions](https://img.shields.io/badge/Contributions-Welcome-brightgreen)
![Website](https://img.shields.io/website?down_color=red&down_message=failed&up_color=blue&up_message=online&url=https%3A%2F%2Fs95.ru)

# Sat 9am 5km - run events system

## TODO

- [ ] Separate page with activities inside event
- [ ] Event specific top menu

## Development

Create `deploy/.env` and `config/database.yml` files:
```shell
cp ./deploy/.env.example ./deploy/.env
cp ./config/database.yml.example ./config/database.yml
```

To build project install `Docker`, `docker-compose` (use V2 on Apple chip) and execute
```shell
make build
make ash
# in docker container
rails db:prepare
rails db:environment:set RAILS_ENV=test
# add secrets
EDITOR=vim rails credentials:edit
```

Now you can run it
```shell
make
```

- Site [http://localhost:3000](http://localhost:3000)
- Admin panel [http://localhost:3000/admin](http://localhost:3000/admin)
- Database panel [http://localhost:3003](http://localhost:3003)
- Bug tracker [Rollbar.com](https://rollbar.com/Urka/Sat_9am_5km/)
- Sidekiq [WebUI](https://s95.ru/sidekiq) for admin users
- [New Relic](https://newrelic.com/)
