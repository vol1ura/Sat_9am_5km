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

After creating application on heroku
```shell
heroku config:set RAILS_MASTER_KEY=$(cat config/master.key)
```

### TODO

1. Add RSpec and write tests to continue with TDD
2. Add module for uploading activities results
3. Add frontend
