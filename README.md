sinatra-tasks
=============
Usage:
```ruby
# in config.ru
require 'sinatra-tasks'
run SinatraTasks::App

# in Rakefile
load 'sinatra-tasks/tasks.rake'

# in order to provide database configuration export environment variable 'DATABASE_URL'
# Example:
ENV['DATABASE_URL'] = "mysql2://user:pass@host/database_name?reconnect=true"
# If heroku, then
$ heroku config:set DATABASE_URL=mysql2://user:pass@host/database_name?reconnect=true
```
