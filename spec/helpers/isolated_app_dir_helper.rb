# frozen_string_literal: true

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

          register Sinatra::ActiveRecordExtension
          set :database, { adapter: 'sqlite3', database: 'tmp/foo.sqlite3' }

  APPFILE

  GEMFILE_CONTENT = <<~GEMFILE.strip
    # frozen_string_literal: true

    source 'https://rubygems.org'

    gem 'sinatra'
    gem 'sqlite3'
    gem 'sinatra-activerecord', path: "#{__dir__ + '/../../'}"
  GEMFILE

  BUNDLER_ENV_VARS = %w(RUBYOPT BUNDLE_PATH BUNDLE_BIN_PATH BUNDLE_GEMFILE).freeze

  def within_isolated_app_dir
    with_clean_env do
      # env.each_pair do |key, value|
      #   ENV[key] = value
      # end
      Dir.mktmpdir('app') do |tmp_dir|
        Dir.chdir(tmp_dir) do
          File.write('Gemfile', GEMFILE_CONTENT)
          File.write('Rakefile', RAKEFILE_CONTENT)
          File.write('app.rb', APPFILE_CONTENT)
          FileUtils.mkdir_p 'db'
          yield
        end
      end
    end
  end

  def with_clean_env
    unset_bundler_env_vars
    yield
  ensure
    restore_env
  end

  def unset_bundler_env_vars
    @original_env = {}
    BUNDLER_ENV_VARS.each do |key|
      @original_env[key] = ENV[key]
      ENV[key] = nil
    end
  end

  def restore_env
    @original_env.each { |key, value| ENV[key] = value }
  end
end
