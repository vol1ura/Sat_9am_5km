# Sat 9am 5km - run event system

Work just started and it's in progress now...

Contributions welcome!

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
2. Add batch operation to join athletes
