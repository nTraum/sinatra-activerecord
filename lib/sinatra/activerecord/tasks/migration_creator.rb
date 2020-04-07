# frozen_string_literal: true

require 'active_record'
require 'fileutils'
require 'pathname'

module Sinatra
  module ActiveRecord
    module Tasks
      # Takes care of creating a new migration file
      class MigrationCreator
        BASE_KLASS = 'ActiveRecord::Migration' + "[#{::ActiveRecord::VERSION::MAJOR}.#{::ActiveRecord::VERSION::MINOR}]"

        attr_reader :name, :version, :filename, :klass, :dirname, :path

        def initialize
          @name    = ENV['NAME']
          @version = ENV['VERSION'] || Time.now.utc.strftime('%Y%m%d%H%M%S')

          # TODO: Strip underscore if no version is given
          @filename = "#{version}_#{name}.rb"
          # TODO: Declare this active support requirement
          @klass = (name || version).camelize

          @dirname  = ::ActiveRecord::Migrator.migrations_paths.first
          @path     = File.join(dirname, filename)

          puts "#{path} created."
        end

        def run
          verify_filename_does_not_exist_yet!
          create_migration_file
        end

        private

        def verify_filename_does_not_exist_yet!
          ::ActiveRecord::Migrator.migrations_paths.each do |directory|
            next unless File.exist?(directory)

            migration_files = Pathname(directory).children
            if migration_files.map { |path| path.basename.to_s.eq?(@filename) }
              puts "#{filename} already exists"
              raise
            end
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
