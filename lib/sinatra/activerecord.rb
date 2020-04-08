# frozen_string_literal: true

require 'active_record'
require 'active_support/core_ext/hash/keys'
require 'erb'
require 'pathname'
require 'sinatra/base'
require 'yaml'

module Sinatra
  module ActiveRecordHelper
    def database
      settings.database
    end
  end

  module ActiveRecord
    def self.registered(app)
      if ENV['DATABASE_URL']
        app.set :database, ENV['DATABASE_URL']
      elsif File.exist?("#{Dir.pwd}/config/database.yml")
        app.set :database_file, "#{Dir.pwd}/config/database.yml"
      end

      app.helpers ActiveRecordHelper

      app.after { ::ActiveRecord::Base.clear_active_connections! }
    end

    def database_file=(path)
      path = File.join(root, path) if Pathname(path).relative? && root
      spec = YAML.safe_load(ERB.new(File.read(path)).result) || {}
      set :database, spec
    end

    def database=(spec)
      if spec.is_a?(Hash) && spec.symbolize_keys[environment.to_sym]
        ::ActiveRecord::Base.configurations = spec.stringify_keys
        ::ActiveRecord::Base.establish_connection(environment.to_sym)
      elsif spec.is_a?(Hash)
        ::ActiveRecord::Base.configurations = { environment.to_sym => spec }
        ::ActiveRecord::Base.establish_connection(spec.stringify_keys)
      else
        ::ActiveRecord::Base.configurations = {}
        ::ActiveRecord::Base.configurations[environment.to_s] =
          ::ActiveRecord::ConnectionAdapters::ConnectionSpecification::ConnectionUrlResolver.new(spec).to_hash
        ::ActiveRecord::Base.establish_connection(spec)
      end
    end

    def database
      ::ActiveRecord::Base
    end
  end

  register ActiveRecord
end
