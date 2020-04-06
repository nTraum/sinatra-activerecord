# frozen_string_literal: true

require 'active_support/core_ext/string/strip'
require 'active_record'
require 'fileutils'
require 'pathname'

module Sinatra
  module ActiveRecord
    module Tasks
      class MigrationCreator
        def new
          unless ENV['NAME']
            puts 'No NAME specified. Example usage: `rake db:create_migration NAME=create_users`'
            fail
          end

          name    = ENV['NAME']
          version = ENV['VERSION'] || Time.now.utc.strftime('%Y%m%d%H%M%S')

          ActiveRecord::Migrator.migrations_paths.each do |directory|
            next unless File.exist?(directory)

            migration_files = Pathname(directory).children
            if duplicate = migration_files.find { |path| path.basename.to_s.include?(name) }
              puts "Another migration is already named \"#{name}\": #{duplicate}."

              fail
            end
          end

          filename = "#{version}_#{name}.rb"
          dirname  = ActiveRecord::Migrator.migrations_paths.first
          path     = File.join(dirname, filename)
          ar_maj   = ActiveRecord::VERSION::MAJOR
          ar_min   = ActiveRecord::VERSION::MINOR
          base     = 'ActiveRecord::Migration'
          base    += "[#{ar_maj}.#{ar_min}]" if ar_maj >= 5

          FileUtils.mkdir_p(dirname)
          File.write path, <<-MIGRATION.strip_heredoc
      class #{name.camelize} < #{base}
        def change
        end
      end
          MIGRATION

          puts path
        end
      end
    end
  end
end
