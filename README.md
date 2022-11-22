[![Quality&Tests](https://github.com/vol1ura/Sat_9am_5km/actions/workflows/rubyonrails.yml/badge.svg)](https://github.com/vol1ura/Sat_9am_5km/actions/workflows/rubyonrails.yml)
[![Test Coverage](https://api.codeclimate.com/v1/badges/5f0c800f5880bee344af/test_coverage)](https://codeclimate.com/github/vol1ura/Sat_9am_5km/test_coverage)
[![Maintainability](https://api.codeclimate.com/v1/badges/5f0c800f5880bee344af/maintainability)](https://codeclimate.com/github/vol1ura/Sat_9am_5km/maintainability)
[![GPLv3 license](https://img.shields.io/badge/License-GPLv3-blue.svg)](http://perso.crans.org/besson/LICENSE.html)
![Contributions](https://img.shields.io/badge/Contributions-Welcome-brightgreen)

# Sat 9am 5km - run events system

## TODO

- [ ] Separate page with activities inside event
- [ ] Event specific top menu

## Development

Create `deploy/.env` and `config/database.yml` files:
```shell
mkdir deploy
cp ./deploy/.env.example ./deploy/.env
cp ./config/database.yml.example ./config/database.yml
```

To build project install `Docker`, `docker-compose` (use V2 on Apple chip) and execute
```shell
make build_proj
make ash
# in docker container
rails db:prepare
rails db:environment:set RAILS_ENV=test
```

Now you can run it
```shell
make
```

- Site [http://localhost:3000](http://localhost:3000)
- Admin panel [http://localhost:3000/admin](http://localhost:3000/admin)
- Database panel [http://localhost:3003](http://localhost:3003)
- Bug tracker [Rollbar.com](https://rollbar.com/Urka/Sat_9am_5km/)
