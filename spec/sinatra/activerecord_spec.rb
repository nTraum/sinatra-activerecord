# frozen_string_literal: true

require 'active_support/core_ext/hash/keys'
require 'fileutils'
require 'pathname'

RSpec.shared_context 'when database.yml exists' do
  let(:database_file) { 'config/database.yml' }
  let(:database_spec) { spec_for(envs: [:test]) }

  before do
    FileUtils.mkdir_p(Pathname.new(database_file).dirname)
    File.write(database_file, database_spec.to_yaml)
  end

  # @param envs [Array<Symbol>] The envs that will end up in the spec.
  # @return [Hash, nil] Spec hash including all specified environments. Returns `nil` if envs is empty.
  def spec_for(envs: [])
    envs.map do |env|
      { env.to_s => { 'adapter' => 'sqlite3', 'database' => "db/#{env}.sqlite3" } }
    end.reduce(:merge)
  end
end

RSpec.shared_context 'when DATABASE_URL exists' do
  let!(:database_url) { 'sqlite3://tmp/foo.sqlite3' }

  around(:each) do |example|
    begin
      ENV['DATABASE_URL'] = database_url
      example.run
    ensure
      ENV.delete('DATABASE_URL')
    end
  end
end

RSpec.shared_examples 'connects to the database' do
  it 'does not raise' do
    expect { subject }.not_to raise_error
  end
end

RSpec.shared_examples 'raises error when connecting to the database' do |error|
  it 'raises' do
    expect { subject }.to raise_error(error)
    expect { subject }.to raise_error(KeyError) unless error
  end
end

RSpec.describe Sinatra::ActiveRecord do
  subject(:app) do
    Class.new(Sinatra::Base) do
      set :root, nil
      register Sinatra::ActiveRecord
    end
  end

  around(:each) do |example|
    within_isolated_app_dir(create_app_files: false, &example)
  end

  describe 'loading database configuration when included' do
    context 'only DATABASE_URL' do
      include_context 'when DATABASE_URL exists'
      include_examples 'connects to the database'
    end

    context 'only database.yml' do
      include_context 'when database.yml exists'
      context 'single database' do
        let(:database_spec) { spec_for(envs: [:test]) }
        include_examples 'connects to the database'
      end

      context 'invalid (empty) spec' do
        let(:root) { Dir.pwd }
        let(:database_spec) { {} }
        include_examples 'raises error when connecting to the database', ActiveRecord::AdapterNotSpecified
      end

      context 'multiple databases' do
        let(:database_spec) { spec_for(envs: %i[development test]) }

        it 'connects to both databases' do
          app
          expect { ActiveRecord::Base.establish_connection(:test) }.not_to raise_error
          expect { ActiveRecord::Base.establish_connection(:development) }.not_to raise_error
        end
      end
    end
  end

  describe '#database_file=' do
    subject do
      app.root = root
      app.database_file = database_file
    end

    context 'invalid (empty) file' do
      include_context 'when database.yml exists'
      let(:root) { Dir.pwd }
      let(:database_file) { 'config/my_db.yml' }
      let(:database_spec) { {} }
      include_examples 'raises error when connecting to the database', ActiveRecord::AdapterNotSpecified
    end

    context 'file does not exist' do
      let(:root) { Dir.pwd }
      let(:database_file) { 'config/my_db.yml' }
      include_examples 'raises error when connecting to the database', Errno::ENOENT
    end

    context '#root is absolute' do
      include_context 'when database.yml exists'
      let(:root) { Dir.pwd }

      context '#database_file is absolute' do
        let(:database_file) { File.join(root, 'config/my_db.yml') }
        include_examples 'connects to the database'
      end

      context '#database_file is relative' do
        let(:database_file) { 'config/my_db.yml' }
        include_examples 'connects to the database'
      end
    end

    context '#root is relative' do
      include_context 'when database.yml exists'
      let(:root) { '.' }

      context '#database_file is absolute' do
        let(:database_file) { File.join(Dir.pwd, 'config/my_db.yml') }
        include_examples 'connects to the database'
      end

      context '#database_file is relative' do
        let(:database_file) { 'config/my_db.yml' }
        include_examples 'connects to the database'
      end
    end

    context '#root is nil' do
      include_context 'when database.yml exists'
      let(:root) { nil }

      context '#database_file is absolute' do
        let(:database_file) { File.join(Dir.pwd, 'config/my_db.yml') }
        include_examples 'connects to the database'
      end

      context '#database_file is relative' do
        let(:database_file) { 'config/my_db.yml' }
        include_examples 'raises error when connecting to the database', ArgumentError
      end
    end
  end

  describe '#database=' do
    subject { app.database = database_spec }

    context 'a hash without environment with string keys' do
      let(:database_spec) { { adapter: 'sqlite3', database: 'db/foo.sqlite3' }.stringify_keys }
      include_examples 'connects to the database'
    end

    context 'a hash without environment with symbol keys' do
      let(:database_spec) { { adapter: 'sqlite3', database: 'db/foo.sqlite3' } }
      include_examples 'connects to the database'
    end

    context 'a hash with environment nesting and symbol keys' do
      let(:database_spec) { { test: { adapter: 'sqlite3', database: 'db/foo.sqlite3' } } }
      include_examples 'connects to the database'
    end

    context 'a hash with environment nesting and string keys' do
      let(:database_spec) { { test: { adapter: 'sqlite3', database: 'db/foo.sqlite3' } }.stringify_keys }
      include_examples 'connects to the database'
    end

    context 'an empty hash' do
      let(:database_spec) { {} }
      include_examples 'raises error when connecting to the database', ActiveRecord::AdapterNotSpecified
    end

    describe 'supports sinatra app env' do
      let(:database_spec) { { test: { adapter: 'sqlite3', database: 'db/foo.sqlite3' } }.stringify_keys }

      context 'as key' do
        before { app.environment = :test }
        include_examples 'connects to the database'
      end

      context 'as string' do
        before { app.environment = 'test' }
        include_examples 'connects to the database'
      end
    end
  end

  describe '#database' do
    subject { app.database }

    context 'when valid database config exists' do
      include_context 'when DATABASE_URL exists'
      it 'returns ActiveRecord::Base' do
        expect(subject).to eq(ActiveRecord::Base)
      end
    end

    context 'when there is no database config' do
      # TODO: Shouldn't this be nil
      # Why is there a database configuration
      xit { is_expected.to eq(nil) }
    end
  end

  describe 'logging' do
    subject { app.database.logger }
    it { is_expected.to be_a(Logger) }
  end
end
