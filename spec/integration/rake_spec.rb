# frozen_string_literal: true

require 'fileutils'

RSpec.shared_context 'isolated app dir' do
  around(:each) do |example|
    within_env_isolated_app_dir(&example)
  end

  let(:command) { ['bundle', 'exec', 'rake', subject, '--trace'] }

  def run_rake_task(custom_command = nil)
    expect(custom_command || command).to run_process
  end

  it 'executes successfully' do
    run_rake_task if execute
  end
end

# Integration specs to verify the various rake tasks.
# Specs in here are executed in an isolated app project directory.
RSpec.describe 'Rake tasks' do
  before do
    pending('ENV var set, pending...') if ENV['SKIP_INTEGRATION_TESTS']
  end

  describe 'db:create_migration' do
    context 'when name argument is given' do
      subject { 'db:create_migration[create_users]' }

      include_context 'isolated app dir' do
        let(:execute) { false }

        it 'generates a migration file' do
          run_rake_task
          expect(Dir['./db/migrate/*.rb']).not_to be_empty
        end

        it 'runs the created migration file' do
          run_rake_task
          run_rake_task(%w[bundle exec rake db:migrate --trace])
        end
      end
    end

    context 'when name is missing' do
      subject { 'db:create_migration' }

      include_context 'isolated app dir' do
        let(:execute) { false }

        it 'fails' do
          expect(command).not_to run_process
          expect(Dir['./db/migrate/*.rb']).to be_empty
        end
      end
    end
  end

  describe 'db:seed' do
    subject { 'db:seed' }
    context 'when a seed file exists' do
      before { FileUtils.touch 'db/seeds.rb' }
      it_behaves_like 'isolated app dir' do
        let(:execute) { true }
      end
    end
  end

  describe 'tasks without dependencies' do
    ['db:create', 'db:create:all', 'db:migrate',
     'db:migrate:redo', 'db:migrate:reset']. each do |task_name|
      describe task_name do
        subject { task_name }

        include_context 'isolated app dir' do
          let(:execute) { true }
        end
      end
    end
  end

  describe 'tasks that need a schema file to exist' do
    include_context 'isolated app dir' do
      let(:execute) { false }

      context 'and it does exist' do
        describe 'db:migrate:status' do
          subject { 'db:migrate:status' }

          it 'runs the task' do
            run_rake_task(%w[bundle exec rake db:migrate --trace])
            run_rake_task
          end
        end

        describe 'db:schema:load' do
          subject { 'db:schema:load' }

          it 'runs the task' do
            run_rake_task(%w[bundle exec rake db:migrate --trace])
            run_rake_task
          end
        end
      end
    end
  end
end
