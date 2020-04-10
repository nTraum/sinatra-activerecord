### Migrating from sinatra-activerecord

If your app used https://github.com/sinatra-activerecord/sinatra-activerecord so far, follow this guide.

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
