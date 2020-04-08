# frozen_string_literal: true

require 'sinatra/activerecord/tasks/migration_creator.rb'

namespace :db do
  desc 'Create a migration (parameters: NAME, VERSION)'
  task :create_migration, [:name] do |_task, args|
    migration_creator = Sinatra::ActiveRecord::Tasks::MigrationCreator.new(args: args.to_a)
    migration_creator.run
  end
end

# The `db:create` and `db:drop` command won't work with a DATABASE_URL because
# the `db:load_config` command tries to connect to the DATABASE_URL, which either
# doesn't exist or isn't able to drop the database. Ignore loading the configs for
# these tasks if a `DATABASE_URL` is present.
if ENV.key? 'DATABASE_URL'
  Rake::Task['db:create'].prerequisites.delete('load_config')
  Rake::Task['db:drop'].prerequisites.delete('load_config')
end
