# Quickstart

Learn how to create a Ruby project with Sinatra and ActiveRecord in two minutes.

First, create an empty project and add a Gemfile:

```sh
mkdir myproject
cd myprojecta
touch Gemfile
```

```ruby
# Gemfile
source 'https://rubygems.org'

gem 'sinatra-activerecord6', require: 'sinatra-activerecord'
gem 'sqlite3'
```

Install the dependencies:

```sh
bundle install
```

Create an `app.rb` file:

```ruby
# app.rb
require 'sinatra'
require 'sinatra/activerecord'

set :database, "sqlite3:database.sqlite3"
```

Create a `Rakefile`:

```ruby
# Rakefile
require 'sinatra/activerecord/rake'

namespace :db do
  task :load_config do
    require_relative 'app.rb'
  end
end
```

Create a migration for creating a users table:

```sh
bundle exec rake db:create_migration[create_users]

# Fix for zsh 'no matches found' error: db:create_migration[create_users]
bundle exec rake db:create_migration\[create_users\]
```

Add code to the migration for creating columns:

```ruby
class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table(:users) do |t|
      t.string :name, index: true
      t.timestamps
    end
  end
end
```

Run the migration:

```sh
bundle exec rake db:migrate
```

Create a User model:

```ruby
# user.rb
class User < ActiveRecord::Base
end
```

Require the User model in your app:

```ruby
# at the bottom of app.rb
require_relative 'user'
```

Write some seeds:

```ruby
# db/seeds.rb
users = [
  { name: 'Bob' },
  { name: 'Susan'}
]

users.each do |u|
  User.create!(u)
end
```

Run the seeds:

```sh
bundle exec rake db:seed
```

Create an `index.erb` file in the `views` directory:

```erb
<%# views/index.erb %>
<!DOCTYPE html>
<html>
<head>
    <title>Users</title>
</head>
<body>
    <ul>
        <% @users.each do |user| %>
            <li><%= user.email %></li>
        <% end %>
    </ul>
</body>
</html>
```

Create a route for the home page

```ruby
# app.rb
get '/' do
  @users = User.all
  erb :index
end
```

Run the server:

```sh
ruby app.rb
```

Adapted from: https://gist.github.com/jtallant/fd66db19e078809dfe94401a0fc814d2
