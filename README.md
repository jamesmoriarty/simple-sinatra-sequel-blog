simple-sinatra-sequel-blog
==========================

A simple blog with Sinatra and Sequel.

start
-----
```bash
DATABASE_URL=postgres://127.0.0.1/<DB_NAME> rackup
```

heroku
------
```bash
$ heroku app:create <APP_NAME>
$ heroku config:set ADMIN_USERNAME=<USERNAME> ADMIN_PASSWORD=<PASSWORD>
$ get push heroku master
```
