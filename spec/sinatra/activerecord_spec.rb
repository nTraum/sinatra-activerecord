# frozen_string_literal: true

require 'fileutils'

RSpec.describe Sinatra::ActiveRecord do
  let(:app) do
    Class.new(Sinatra::Base) do
      set :root, nil
      register Sinatra::ActiveRecord
    end
  end

  describe 'database spec' do
    context 'when DATABASE_URL is given' do
      let!(:database_url) { 'sqlite3:///tmp/foo.sqlite3' }

      around(:each) do |example|
        begin
          ENV['DATABASE_URL'] = database_url
          example.run
        ensure
          ENV.delete('DATABASE_URL')
        end
      end

      it 'establishes the connection with a database url' do
        app
        expect { ActiveRecord::Base.connection }.not_to raise_error
      end
    end
  end

  it 'exposes ActiveRecord::Base' do
    expect(app.database).to eq ActiveRecord::Base
  end

  it 'establishes the connection with a hash' do
    app.database = { adapter: 'sqlite3', database: 'tmp/foo.sqlite3' }

    expect { ActiveRecord::Base.connection }.not_to raise_error
  end

  it 'handles namespacing into environments' do
    app.environment = :development
    app.database = { development: { adapter: 'sqlite3', database: 'tmp/foo.sqlite3' } }

    expect { ActiveRecord::Base.connection }.not_to raise_error
  end

  it 'allows settings environments as Strings' do
    app.environment = 'development'
    app.database = { development: { adapter: 'sqlite3', database: 'tmp/foo.sqlite3' } }

    expect { ActiveRecord::Base.connection }.not_to raise_error
  end

  it 'raises an appropriate error when the database spec is invalid' do
    expect { app.database = {} }.to raise_error(ActiveRecord::AdapterNotSpecified)
  end

  it "doesn't try to establish connection when database isn't set" do
    expect { app.database }.not_to raise_error
  end

  it 'allows specifying database through a file' do
    app.database_file = 'spec/fixtures/database.yml'

    expect { ActiveRecord::Base.connection }.not_to raise_error
  end

  it 'allows specifying multiple databases' do
    app.root = 'spec/fixtures'
    app.database_file = 'database.yml'

    expect { ActiveRecord::Base.establish_connection(:test) }.not_to raise_error
    expect { ActiveRecord::Base.establish_connection(:another_test) }.not_to raise_error
  end

  it 'expands database file path from the app root if present' do
    app.root = 'spec/fixtures'
    app.database_file = 'database.yml'

    expect { ActiveRecord::Base.connection }.not_to raise_error
  end

  it "doesn't expand the database file path from the app root if the path is absolute" do
    app.root = 'spec/fixtures'
    app.database_file = "#{Dir.pwd}/spec/fixtures/database.yml"

    expect { ActiveRecord::Base.connection }.not_to raise_error
  end

  it 'raises an error on invalid database.yml' do
    FileUtils.touch('tmp/database.yml')

    expect { app.database_file = 'tmp/database.yml' }.to raise_error(ActiveRecord::AdapterNotSpecified)
  end

  it 'raises an error on missing database.yml' do
    expect { app.database_file = 'foo.yml' }.to raise_error(Errno::ENOENT)
  end
end
