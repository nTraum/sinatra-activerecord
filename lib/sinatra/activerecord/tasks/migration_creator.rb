# frozen_string_literal: true

require 'active_record'
require 'active_support/core_ext/string/inflections'
require 'fileutils'
require 'pathname'

module Sinatra
  module ActiveRecord
    module Tasks
      # Takes care of creating a new migration file
      class MigrationCreator
        BASE_KLASS = 'ActiveRecord::Migration' + "[#{::ActiveRecord::Migration.current_version}]"
        NAME_MISSING = 'NAME missing, usage: rake db:create_migration[name]'

        attr_reader :args, :name, :version, :filename, :klass, :dirname, :path

        def initialize(args:)
          @args = args
          @name = parse_name_from!(args)
          @version = Time.now.utc.strftime('%Y%m%d%H%M%S')
          @filename = deduct_filename_from(name, version)
          @klass = deduct_klass_from(name)
          @dirname = ::ActiveRecord::Migrator.migrations_paths.first
          @path = File.join(dirname, filename)
        end

        def run
          verify_filename_does_not_exist_yet!
          create_migration_file
          puts "#{path} created."
        end

        private

        def parse_name_from!(args)
          name = args.first
          raise(ArgumentError, NAME_MISSING) unless name

          name
        end

        def deduct_filename_from(name, version)
          "#{version}_#{name}.rb".underscore
        end

        def deduct_klass_from(name)
          name.camelize
        end

        def verify_filename_does_not_exist_yet!
          migration_paths = ::ActiveRecord::Migrator.migrations_paths

          migration_paths.each do |migration_path|
            migration_file_path = Pathname.new(migration_path) + filename
            raise(ArgumentError, "#{migration_file_path} already exists") if File.exist?(migration_file_path)
          end
        end

        def create_migration_file
          FileUtils.mkdir_p(dirname)
          File.write path, <<~MIGRATION
            class #{klass} < #{BASE_KLASS}
                def change
                end
            end
          MIGRATION
        end
      end
    end
  end
end
