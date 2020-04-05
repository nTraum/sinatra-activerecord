# frozen_string_literal: true

module IsolatedAppDirHelper
  RAKEFILE_CONTENT = <<~RAKEFILE.strip
    # frozen_string_literal: true

    require 'sinatra/activerecord/rake'
    require_relative 'app.rb'
  RAKEFILE

  APPFILE_CONTENT = <<~APPFILE.strip
    # frozen_string_literal: true

    require 'sinatra'
    require 'sinatra/activerecord'

          register Sinatra::ActiveRecordExtension
          set :database, { adapter: 'sqlite3', database: 'tmp/foo.sqlite3' }

  APPFILE

  BUNDLER_ENV_VARS = %w(RUBYOPT BUNDLE_PATH BUNDLE_BIN_PATH BUNDLE_GEMFILE).freeze

  def within_isolated_app_dir
    Dir.mktmpdir('app') do |tmp_dir|
      Dir.chdir(tmp_dir) do
        File.write('Rakefile', RAKEFILE_CONTENT)
        File.write('app.rb', APPFILE_CONTENT)
        FileUtils.mkdir_p 'db'
        yield
      end
    end
  end
end
