# frozen_string_literal: true

require 'sinatra/base'
require 'active_record'
require 'active_support/core_ext/hash/keys'

require 'logger'
require 'pathname'
require 'yaml'
require 'erb'

module Sinatra
  module ActiveRecordHelper
    def database
      settings.database
    end
  end

  module ActiveRecordExtension
    def self.registered(app)
      if ENV['DATABASE_URL']
        app.set :database, ENV['DATABASE_URL']
      elsif File.exist?("#{Dir.pwd}/config/database.yml")
        app.set :database_file, "#{Dir.pwd}/config/database.yml"
      end

      unless defined?(Rake) || %i[test production].include?(app.settings.environment)
        ActiveRecord::Base.logger = Logger.new(STDOUT)
      end

      app.helpers ActiveRecordHelper

      # TODO: This does not seem to be the right place
      # https://github.com/rails/rails/blob/fc4ef77d47c0aff1f3477f42261c1b11e2afecfc/activerecord/lib/active_record/railtie.rb#L255
      # Rails clears connections once after the application booted up, not after every request.
      app.after { ActiveRecord::Base.clear_active_connections! }
    end

    def database_file=(path)
      path = File.join(root, path) if Pathname(path).relative? && root
      spec = YAML.safe_load(ERB.new(File.read(path)).result) || {}
      set :database, spec
    end

    def database=(spec)
      if spec.is_a?(Hash) && spec.symbolize_keys[environment.to_sym]
        ActiveRecord::Base.configurations = spec.stringify_keys
        ActiveRecord::Base.establish_connection(environment.to_sym)
      elsif spec.is_a?(Hash)
        ActiveRecord::Base.configurations[environment.to_s] = spec.stringify_keys
        ActiveRecord::Base.establish_connection(spec.stringify_keys)
      else
        ActiveRecord::Base.establish_connection(spec)
        ActiveRecord::Base.configurations ||= {}
        ActiveRecord::Base.configurations[environment.to_s] =
          ActiveRecord::ConnectionAdapters::ConnectionSpecification::ConnectionUrlResolver.new(spec).to_hash
      end
    end

    def database
      ActiveRecord::Base
    end
  end

  register ActiveRecordExtension
end
