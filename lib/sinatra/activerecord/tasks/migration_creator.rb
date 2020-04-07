# frozen_string_literal: true

require 'active_record'
require 'fileutils'
require 'pathname'

module Sinatra
  module ActiveRecord
    module Tasks
      class MigrationCreator
        def initialize
          name    = ENV['NAME']
          version = ENV['VERSION'] || Time.now.utc.strftime('%Y%m%d%H%M%S')
          filename = "#{version}_#{name}.rb"
          klass = (name || version).camelize

          ::ActiveRecord::Migrator.migrations_paths.each do |directory|
            next unless File.exist?(directory)

            migration_files = Pathname(directory).children
            if migration_files.map { |path| path.basename.to_s.eq?(filename) }
              puts "#{filename} already exists"
              raise
            end
          end

          dirname  = ::ActiveRecord::Migrator.migrations_paths.first
          path     = File.join(dirname, filename)
          ar_maj   = ::ActiveRecord::VERSION::MAJOR
          ar_min   = ::ActiveRecord::VERSION::MINOR
          base     = 'ActiveRecord::Migration'
          base    += "[#{ar_maj}.#{ar_min}]" if ar_maj >= 5

          FileUtils.mkdir_p(dirname)
          File.write path, <<~MIGRATION
            class #{klass} < #{base}
                def change
                end
            end
          MIGRATION

          puts "#{path} created."
        end
      end
    end
  end
end
