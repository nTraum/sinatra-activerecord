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
    DATABASE_FILE_RELATIVE_ERROR_MESSAGE = <<~MSG
      database_file must not be relative when root is not defined.
      Change database_file to an absolute path or set the app root of your sinatra app instead.
    MSG

    # Registers the extension for the specified app.
    # @param app [Sinatra::Base] The sinatra app.
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
      if Pathname(path).relative?
        raise(ArgumentError, DATABASE_FILE_RELATIVE_ERROR_MESSAGE) unless root

        path = File.join(root, path)
      end
      spec = YAML.safe_load(ERB.new(File.read(path)).result) || {}
      set :database, spec
    end

    def database=(spec)
      # with environment?
      if spec.is_a?(Hash) && spec.symbolize_keys[environment.to_sym]
        ::ActiveRecord::Base.configurations = spec.stringify_keys
        ::ActiveRecord::Base.establish_connection(environment.to_sym)
      elsif spec.is_a?(Hash)
        # without environment?
        ::ActiveRecord::Base.configurations = { environment.to_sym => spec }
        ::ActiveRecord::Base.establish_connection(spec.stringify_keys)
      else
        ::ActiveRecord::Base.configurations = {}
        ::ActiveRecord::Base.establish_connection(spec)
      end
    end

    def database
      ::ActiveRecord::Base
    end
  end

  register ActiveRecord
end
