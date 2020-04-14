# frozen_string_literal: true

require 'active_record'
require 'active_support/core_ext/hash/keys'
require 'erb'
require 'logger'
require 'pathname'
require 'sinatra/base'
require 'yaml'

require_relative 'activerecord/version'

module Sinatra
  # Sinatra extension that provides a {#database} helper method to access the database.
  # @note This module should not be used stand-alone, use {Sinatra::ActiveRecord} instead.
  module ActiveRecordHelper
    # @return [ActiveRecord::Base] Returns ActiveRecord's database.
    def database
      settings.database
    end
  end

  # Sinatra extension that provides ActiveRecord integration.
  module ActiveRecord
    DATABASE_FILE_RELATIVE_ERROR_MESSAGE = <<~MSG
      database_file must not be relative when root is not defined.
      Change database_file to an absolute path or set the app root of your sinatra app instead.
    MSG

    # Registers the extension for the specified app:
    # - Configures the logger to STDOUT
    # - Checks for DATABASE_ENV or default path
    # - Establishes database connection
    # @param app [Sinatra::Base] The sinatra app.
    def self.registered(app)
      ::ActiveRecord::Base.logger = Logger.new(STDOUT) unless ::ActiveRecord::Base.logger

      if ENV['DATABASE_URL']
        app.set :database, ENV['DATABASE_URL']
      elsif File.exist?("#{Dir.pwd}/config/database.yml")
        app.set :database_file, "#{Dir.pwd}/config/database.yml"
      end

      app.helpers ActiveRecordHelper

      app.after { ::ActiveRecord::Base.clear_active_connections! }
    end

    # Sets the database spec by reading a yaml file
    # @param path [String] Relative or absolute path to database configuration file.
    #  If the path is relative, `root` must be specified.
    # @see sinatrarb.com/configuration.html
    # @raise [ArgumentError]
    def database_file=(path)
      if Pathname(path).relative?
        raise(ArgumentError, DATABASE_FILE_RELATIVE_ERROR_MESSAGE) unless root

        path = File.join(root, path)
      end
      spec = YAML.safe_load(ERB.new(File.read(path)).result) || {}
      set :database, spec
    end

    def database=(spec)
      if spec.is_a?(Hash) && spec.symbolize_keys[environment.to_sym]
        connect_with_environments(spec)
      elsif spec.is_a?(Hash)
        connect_with_app_env(spec)
      else
        connect_with_url(spec)
      end
    end

    def database
      ::ActiveRecord::Base
    end

    private

    def connect_with_environments(spec)
      ::ActiveRecord::Base.configurations = spec.stringify_keys
      ::ActiveRecord::Base.establish_connection(environment.to_sym)
    end

    def connect_with_app_env(spec)
      ::ActiveRecord::Base.configurations = { environment.to_sym => spec }
      ::ActiveRecord::Base.establish_connection(spec.stringify_keys)
    end

    def connect_with_url(url)
      ::ActiveRecord::Base.configurations = {}
      ::ActiveRecord::Base.establish_connection(url)
    end
  end

  register ActiveRecord
end
