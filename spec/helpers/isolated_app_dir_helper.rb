# frozen_string_literal: true

# Provides temporary app directories to for testing
module IsolatedAppDirHelper
  RAKEFILE_CONTENT = <<~RAKEFILE.strip
    # frozen_string_literal: true

    require 'sinatra/activerecord/rake'

    namespace :db do
      task :load_config do
        require_relative 'app.rb'
      end
    end
  RAKEFILE

  APPFILE_CONTENT = <<~APPFILE.strip
    # frozen_string_literal: true

    require 'sinatra'
    require 'sinatra/activerecord'

    set :database, { adapter: 'sqlite3', database: 'db/database.sqlite3' }

  APPFILE

  GEMFILE_CONTENT = <<~GEMFILE.strip
    # frozen_string_literal: true

    source 'https://rubygems.org'

    gem 'sqlite3'
    gem 'sinatra-activerecord6', path: "#{__dir__ + '/../../'}", require: 'sinatra-activerecord'
  GEMFILE

  APP_ENV_VARS = %w[RACK_ENV APP_ENV].freeze

  # Strips out Bundler and App environment variables and provides an app dir
  # @see #within_isolated_app_dir
  # @see #with_clean_env
  def within_env_isolated_app_dir
    Bundler.with_unbundled_env do
      with_clean_env do
        `bundle install`
        within_isolated_app_dir(create_app_files: true) do
          yield
        end
      end
    end
  end

  # Creates a temporary app dir
  # @param create_app_files [Boolean] Creates a Gemfile, Rakefile and app.rb if true
  def within_isolated_app_dir(create_app_files:)
    Dir.mktmpdir('app') do |tmp_dir|
      Dir.chdir(tmp_dir) do
        if create_app_files
          File.write('Gemfile', GEMFILE_CONTENT)
          File.write('Rakefile', RAKEFILE_CONTENT)
          File.write('app.rb', APPFILE_CONTENT)
          Dir.mkdir('db')
        end
        yield
      end
    end
  end

  # Strips out Bundler and App environment variables
  def with_clean_env
    unset_env_vars
    yield
  ensure
    restore_env
  end

  def unset_env_vars
    @original_env = {}
    APP_ENV_VARS.each do |key|
      @original_env[key] = ENV[key]
      ENV[key] = nil
    end
  end

  def restore_env
    @original_env.each { |key, value| ENV[key] = value }
  end
end
