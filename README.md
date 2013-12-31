simple-sinatra-sequel-blog [![Dependency Status](https://gemnasium.com/jamesmoriarty/simple-sinatra-sequel-blog.png)](https://gemnasium.com/jamesmoriarty/simple-sinatra-sequel-blog)
==========================

A simple blog with Sinatra and Sequel. ~150 lines of code.

Live example: [telos.co.nz](http://telos.co.nz/)

start
-----
```bash
$ DATABASE_URL=postgres://127.0.0.1/<DB_NAME> rackup
```

heroku
------
```bash
$ heroku app:create <APP_NAME>
$ heroku config:set ADMIN_USERNAME=<USERNAME> ADMIN_PASSWORD=<PASSWORD>
$ git push heroku master
```
