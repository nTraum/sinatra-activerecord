# frozen_string_literal: true

require 'sinatra/activerecord/tasks/migration_creator'

RSpec.shared_context 'isolated db dir' do
  around(:each) do |example|
    within_isolated_app_dir(create_app_files: true, &example)
  end
end

RSpec.shared_examples 'creates migration file' do |expected_migration_name|
  it 'creates a migration file with the specified name' do
    expected_timestamp = Time.now.utc.strftime('%Y%m%d%H%M%S')
    expected_filename = "#{expected_timestamp}_#{expected_migration_name}.rb"

    expect { subject }.to output(anything).to_stdout

    expect(File.exist?("db/migrate/#{expected_filename}")).to eq(true)
  end
end

RSpec.describe Sinatra::ActiveRecord::Tasks::MigrationCreator do
  describe '#run' do
    include_context 'isolated db dir'

    around(:each) do |example|
      Timecop.freeze { example.run }
    end

    subject { described_class.new(args: args).run }

    describe 'migration file name' do
      context 'when there is a name specified' do
        let(:name) { 'create_users' }
        let(:args) { [name] }

        context 'and the file does not exist yet' do
          it_behaves_like 'creates migration file', 'create_users'
        end

        context 'and the name is CamelCased' do
          let(:name) { 'CreateUsers' }
          let(:args) { [name] }

          it_behaves_like 'creates migration file', 'create_users'
        end

        context 'and the file already exists' do
          subject { 2.times { described_class.new(args: args).run } }

          it 'raises ArgumentError' do
            expect { subject }.to raise_error(ArgumentError).and output.to_stdout
          end
        end
      end

      context 'when there is no name specified' do
        let(:args) { [] }
        it 'raises ArgumentError' do
          expect { subject }.to raise_error(ArgumentError)
        end
      end
    end
  end
end
