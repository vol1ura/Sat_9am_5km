[![Quality&Tests](https://github.com/vol1ura/Sat_9am_5km/actions/workflows/rubyonrails.yml/badge.svg)](https://github.com/vol1ura/Sat_9am_5km/actions/workflows/rubyonrails.yml)
[![GPLv3 license](https://img.shields.io/badge/License-GPLv3-blue.svg)](http://perso.crans.org/besson/LICENSE.html)
![Contributions](https://img.shields.io/badge/Contributions-Welcome-brightgreen)

# Sat 9am 5km - run event system

Work just started and it's in progress now...

## Development

To build project execute
```shell
make build_proj
```

Now you can run it
```shell
make proj
```

## Deploy

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
heroku pg:backups:capture --app <my-app-name>
heroku pg:backups:download --app <my-app-name>
```

### TODO

1. Add frontend
2. Up and down athletes in protocol
3. Insert and remove athletes
4. Adding volunteers through Athlete menu by item action