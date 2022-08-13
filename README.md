[![Quality&Tests](https://github.com/vol1ura/Sat_9am_5km/actions/workflows/rubyonrails.yml/badge.svg)](https://github.com/vol1ura/Sat_9am_5km/actions/workflows/rubyonrails.yml)
[![Test Coverage](https://api.codeclimate.com/v1/badges/5f0c800f5880bee344af/test_coverage)](https://codeclimate.com/github/vol1ura/Sat_9am_5km/test_coverage)
[![Maintainability](https://api.codeclimate.com/v1/badges/5f0c800f5880bee344af/maintainability)](https://codeclimate.com/github/vol1ura/Sat_9am_5km/maintainability)
[![GPLv3 license](https://img.shields.io/badge/License-GPLv3-blue.svg)](http://perso.crans.org/besson/LICENSE.html)
![Contributions](https://img.shields.io/badge/Contributions-Welcome-brightgreen)

# Sat 9am 5km - run event system

## TODO

- [ ] FEATURE: Insert and remove athletes in protocol
- [x] FEATURE: Volunteers schedule list
- [ ] FEATURE: Diagrams tab on activity show page - pie men/women, gist bar by result with median
- [ ] FEATURE: Diagrams tab on clubs index page - men/women in club, counts, top athlete
- [ ] FEATURE: Diagrams tab on athlete page - results dynamics,
- [x] Top50 results for men and women
- [ ] Separate page with activities inside event
- [ ] Event specific top menu
- [ ] Add Redis and configure adapter for async jobs
- [x] Setup logrotate

## Development

Create `deploy/.env` and `config/database.yml` files:
```shell
cp .env.example ./deploy/.env
cp ./config/database.yml.example ./config/database.yml
```

To build project install `Docker`, `docker-compose` and execute
```shell
make build_proj
```

Now you can run it
```shell
make
```
