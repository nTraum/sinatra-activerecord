TODO

* use sintra root dir for activerecord paths
* use sinatra env for activerecord env
* Fix database configuration options
* Fix README

* Specs
* Add spec that verifies APP_ENV works
* Add spec that verified RACK_ENV fallback works
* Add spec that defines database configuration behavior, DATABASE_URL before everything else etc
* Add specs for all supported ruby versions

* Maybe
* ActiveRecord 5 support?

# sinatra-activerecord6

[![CircleCI](https://circleci.com/gh/nTraum/sinatra-activerecord6.svg?style=shield)](https://app.circleci.com/pipelines/github/nTraum/sinatra-activerecord6) [![codecov](https://codecov.io/gh/nTraum/sinatra-activerecord6/branch/master/graph/badge.svg)](https://codecov.io/gh/nTraum/sinatra-activerecord6)

sinatra-activerecord6 allows you to use ActiveRecord in your Sinatra app.

# Requirements

* Ruby 2.4 or newer
* Sinatra 2 or newer
* ActiveRecord 6 or newer

# Installation

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

#### Configure single database (simple)

If you don't care about your environment, you can set the `DATABASE_URL` and start your app:

```sh
DATABASE_URL=postgresql://localhost/blog_development?pool=5 ruby app.rb
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

set :database, { adapter: 'postgresql',  database: 'blog'_development, pool: 5 }
```

You should only use **one** way of configuring your database not not mix them.

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


### Create migrations

See https://guides.rubyonrails.org/active_record_migrations.html first for a general introduction.

We can't use `rails generate migration create_users`, so we'll use `rake db:create_migration[create_users]` instead. If you use zsh shell and see this error, escape the arguments.

```sh
bundle exec rake db:create_migration[create_users]

# Fix for zsh no matches found error: db:create_migration[create_users]
bundle exec rake db:create_migration\[create_users\]
```

### Test integration


## Setup

Put it in your `Gemfile`, along with the adapter of your database. For
simplicity, let's assume you're using SQLite:

```ruby
gem "sinatra-activerecord"
gem "sqlite3"
gem "rake"
```

Now require it in your Sinatra application, and establish the database
connection:

```ruby
# app.rb
require "sinatra/activerecord"

set :database, {adapter: "sqlite3", database: "foo.sqlite3"}
# or set :database_file, "path/to/database.yml"
```

If you have a `config/database.yml`, it will automatically be loaded, no need
to specify it. Also, in production, the `$DATABASE_URL` environment variable
will automatically be read as the database (if you haven't specified otherwise).

Note that in **modular** Sinatra applications you will need to first register
the extension:

```ruby
class YourApplication < Sinatra::Base
  register Sinatra::ActiveRecord
end
```

Now require the rake tasks and your app in your `Rakefile`:

```ruby
# Rakefile
require "sinatra/activerecord/rake"

namespace :db do
  task :load_config do
    require "./app"
  end
end
```

In the Terminal test that it works:

```sh
$ bundle exec rake -T
rake db:create            # Create the database from DATABASE_URL or config/database.yml for the current Rails.env (use db:create:all to create all dbs in the config)
rake db:create_migration  # Create a migration (parameters: NAME, VERSION)
rake db:drop              # Drops the database using DATABASE_URL or the current Rails.env (use db:drop:all to drop all databases)
rake db:fixtures:load     # Load fixtures into the current environment's database
rake db:migrate           # Migrate the database (options: VERSION=x, VERBOSE=false)
rake db:migrate:status    # Display status of migrations
rake db:rollback          # Rolls the schema back to the previous version (specify steps w/ STEP=n)
rake db:schema:dump       # Create a db/schema.rb file that can be portably used against any DB supported by AR
rake db:schema:load       # Load a schema.rb file into the database
rake db:seed              # Load the seed data from db/seeds.rb
rake db:setup             # Create the database, load the schema, and initialize with the seed data (use db:reset to also drop the db first)
rake db:structure:dump    # Dump the database structure to db/structure.sql
rake db:version           # Retrieves the current schema version number
```

And that's it, you're all set :)

## Usage

You can create a migration:

```sh
$ bundle exec rake db:create_migration NAME=create_users
```

This will create a migration file in your migrations directory (`./db/migrate`
by default), ready for editing.

```ruby
class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name
    end
  end
end
```

Now migrate the database:

```sh
$ bundle exec rake db:migrate
```

You can also write models:

```ruby
class User < ActiveRecord::Base
  validates_presence_of :name
end
```

You can put your models anywhere you want, only remember to require them if
they're in a separate file, and that they're loaded after `require "sinatra/activerecord"`.

Now everything just works:

```ruby
get '/users' do
  @users = User.all
  erb :index
end

get '/users/:id' do
  @user = User.find(params[:id])
  erb :show
end
```

A nice thing is that the `ActiveRecord::Base` class is available to
you through the `database` variable:

```ruby
if database.table_exists?('users')
  # Do stuff
else
  raise "The table 'users' doesn't exist."
end
```

# History

This gem was originally made in 2009 by Blake Mizerany, creator of Sinatra.

# License

[https://github.com/nTraum/sinatra-activerecord6/blob/master/LICENSE](MIT)
