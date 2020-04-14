# frozen_string_literal: true

seed_loader = Class.new do
  def load_seed
    load "#{ActiveRecord::Tasks::DatabaseTasks.db_dir}/seeds.rb"
  end
end

ActiveRecord::Tasks::DatabaseTasks.tap do |config|
  config.root                   = Rake.application.original_dir
  config.env                    = ENV['APP_ENV'] || 'development'
  config.db_dir                 = 'db'
  config.migrations_paths       = ['db/migrate']
  config.fixtures_path          = 'test/fixtures'
  config.seed_loader            = seed_loader.new
  config.database_configuration = ActiveRecord::Base.configurations
end

# db:load_config must be overriden manually to load the Sinatra app
Rake::Task['db:seed'].enhance(['db:load_config'])
Rake::Task['db:load_config'].clear

# define Rails' tasks as no-op, we have our own `db:load_config` task that takes care of it
Rake::Task.define_task('db:environment')
Rake::Task['db:test:deprecated'].clear if Rake::Task.task_defined?('db:test:deprecated')
