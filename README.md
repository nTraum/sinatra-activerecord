# sinatra-activerecord6

[![CircleCI](https://circleci.com/gh/nTraum/sinatra-activerecord6.svg?style=shield)](https://app.circleci.com/pipelines/github/nTraum/sinatra-activerecord6) [![codecov](https://codecov.io/gh/nTraum/sinatra-activerecord6/branch/master/graph/badge.svg)](https://codecov.io/gh/nTraum/sinatra-activerecord6)

sinatra-activerecord6 allows you to use ActiveRecord in your Sinatra app.

## Requirements

* Ruby 2.5 or newer
* Sinatra 2 or newer
* ActiveRecord 6 or newer

## Installation

See [Migrating from sinatra-activerecord](./doc/migrating_from_sinatra_activerecord.md) if you want to migrate from an existing app that used `sinatra-activerecord` so far.

Add `sinatra-activerecord6` to your Gemfile:

```ruby
gem 'sinatra-activerecord6', require: 'sinatra-activerecord'
```

Add your database adapter to your Gemfile:

```ruby
# SQLite
gem 'sqlite3'
```

Run bundle install:

```sh
bundle install
```

## Usage

This chapter provides a deep dive into many functionalities of the gem, if you just want to get something going quickly, see the [Quickstart](./doc/quickstart.md) instead come back here later if you want.

### Configure your sinatra app

Require the gem:

```ruby
# app.rb -
require 'sinatra'
require 'sinatra/activerecord'

set :database, 'sqlite3:database.sqlite3'
```

If you subclass from `ActiveRecord::Base` you have to the additionally register the extension:

```ruby
# app.rb -
require 'sinatra'
require 'sinatra/activerecord'

class App < Sinatra::Base
  register Sinatra::ActiveRecord
  set :database, 'sqlite3:database.sqlite3'
end
```

#### Configure single database (simple)

If you don't care about your environment, you can set the `DATABASE_URL` and start your app:

```sh
DATABASE_URL='postgresql://localhost/blog_development?pool=5' ruby app.rb
```

You can also specify a configuration file `config/database.yml`:

```yaml
adapter: postgresql
database: blog_development
pool: 5
```

If you prefer the configuration to happen within your app, use the `database` setting instead.

```ruby
# app.rb

set :database, { adapter: 'postgresql',  database: 'blog_development', pool: 5 }
```

You should only use **one** way of configuring your database and not mix them.

#### Configure mulitple databases (Rails way)

See [Rails database configuration](https://guides.rubyonrails.org/configuring.html#configuring-a-database) for a general introduction.

The gem configures ActiveRecord to work well with Sinatra's `environment` behavior (see [docs](http://sinatrarb.com/configuration.html)). When you want to specify different databases for environments (as in Rails), ActiveRecord will choose the database that is defined via `environment`. If `environment` is empty, Sinatra will set it to whatever the environment variable `APP_ENV` is (or default to `development`).

```sh
# Will connect to the test database
APP_ENV=test bundle exec rspec

# Will connect to the development database
bundle exec rackup
```

You can add specify a configuration file in `config/database.yml`.

```yaml
development:
  adapter: sqlite3
  database: db/development.sqlite3
  pool: 5
  timeout: 5000

development:
  adapter: sqlite3
  database: db/test.sqlite3
  pool: 5
  timeout: 5000
```

If your file lives somewhere else, change the `database_file` setting in your app:

```ruby
# app.rb

set :database_file, '/deploy/config/deploy_database.yml'
```

#### Connection preference

TODO this needs to be specced so badly.

### Add database tasks to Rake

Edit your `Rakefile` to include the database tasks. We will also have to require our Sinatra app:

```ruby
# Rakefile
require 'sinatra/activerecord/rake'

namespace :db do
  task :load_config do
    require_relative 'app.rb'
  end
end
```

### Create migrations

See https://guides.rubyonrails.org/active_record_migrations.html first for a general introduction.

We can't use `rails generate migration create_users`, so we'll use `rake db:create_migration[create_users]` instead. If you use zsh shell and see this error, escape the arguments.

```sh
bundle exec rake db:create_migration[create_users]

# Fix for zsh no matches found error: db:create_migration[create_users]
bundle exec rake db:create_migration\[create_users\]
```

# License

[MIT](https://github.com/nTraum/sinatra-activerecord6/blob/master/LICENSE)

# TODO

* use sintra root dir for activerecord paths
* Fix database configuration options
* README should include simple usage and link to advanced configuration instead of the other way around

* Specs
* Add spec that verifies APP_ENV works
* Add spec that defines database configuration behavior, DATABASE_URL before everything else etc
