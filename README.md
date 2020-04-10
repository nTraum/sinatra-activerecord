# Changes
* Drop support for Ruby 2.3 and older
* Drop support for ActiveRecord 5 and older
* Drop support for Sinatra < 2

TODO
* use sintra root dir for activerecord paths
* use sinatra env for activerecord env
* Fix database configuration options
* Fix README
  * * Migration from sinatra-activerecord
  * *

* Specs
* Add spec that verifies APP_ENV works
* Add spec that verified RACK_ENV fallback works
* Add spec that defines database configuration behavior, DATABASE_URL before everything else etc
* Add specs for all supported ruby versions

* Maybe
* ActiveRecord 5 support?

# sinatra-activerecord6

[![CircleCI](https://circleci.com/gh/nTraum/sinatra-activerecord.svg?style=shield)](https://app.circleci.com/pipelines/github/nTraum/sinatra-activerecord) [![codecov](https://codecov.io/gh/nTraum/sinatra-activerecord/branch/master/graph/badge.svg)](https://codecov.io/gh/nTraum/sinatra-activerecord)

sinatra-activerecord6 allows you to use ActiveRecord in your Sinatra app.

# Requirements

* Ruby 2.4 or newer
* Sinatra 2 or newer
* ActiveRecord 6 or newer

# Installation

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

This library provides a Sinatra extension that connects to the database via ActiveRecord and Rake tasks to interact with the database.

### Configure your sinatra app

ActiveRecord integrates with Sinatra's `environment` behavior (see [docs](http://sinatrarb.com/configuration.html)). When you want to specify different databases for environments (as in Rails), ActiveRecord will choose the database that is defined via `environment`. If `environment` is empty, Sinatra will set it to whatever the environment variable `APP_ENV` is (or default to `development`).


### Add database tasks to Rake


### Create migrations

See https://guides.rubyonrails.org/active_record_migrations.html first for a general introduction.

We can't use `rails generate migration create_users`, so we'll use `rake db:create_migration[create_users]` instead. If you use zsh shell and see this error, escape the arguments.

```sh
bundle exec rake db:create_migration[create_users]

# Fix for zsh no matches found error: db:create_migration[create_users]
bundle exec rake db:create_migration\[create_users\]
```

### Migrating from sinatra-activerecord

Update your Gemfile:

```ruby
# Gemfile

# gem 'sinatra-activerecord'
gem 'sinatra-activerecord6', require: 'sinatra-activerecord'
```

Update your Sinatra app to use new extension:

```
# app.rb

# register Sinatra::ActiveRecordExtension
register Sinatra::ActiveRecord

```

Install gems:

```sh
bundle install
```

Do a test run or run your tests now. Depending on your sinatra app and database configuration, this maybe was the last step.
In short, the following things changed:
- Database configuration: Sinatra's env var `APP_ENV` / `environment` is treated sanely, see TODO
- `rake db:create_migration` syntax changed, see TODO
- Logging: ActiveRecord now logs to STDOUT by default, see TODO

If you need to upgrade to a more recent version of ActiveRecord first, check https://guides.rubyonrails.org/upgrading_ruby_on_rails.html for ActiveRecord related changes.

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

## History

This gem was made in 2009 by Blake Mizerany, creator of Sinatra.

## Social

You can follow me on Twitter, I'm [@jankomarohnic](http://twitter.com/jankomarohnic).

## License

[MIT](https://github.com/janko-m/sinatra-activerecord/blob/master/LICENSE)
