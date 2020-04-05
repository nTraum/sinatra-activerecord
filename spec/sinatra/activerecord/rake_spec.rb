# frozen_string_literal: true

require 'fileutils'

RSpec.shared_context 'Rake task executes successfully' do
  around(:each) do |example|
    within_isolated_app_dir(&example)
  end

  let(:command) { ['bundle', 'exec', 'rake', subject, '--trace'] }

  def run_rake_task
    expect(command).to run_process
  end

  it 'executes successfully' do
    run_rake_task if execute
  end
end

# Integration tests?
RSpec.describe 'Rake tasks' do
  describe 'db:create_migration' do
    context 'when no argument is given' do
      subject { 'db:create_migration' }

      around(:each) do |example|
        Timecop.freeze { example.run }
      end

      include_context 'Rake task executes successfully' do
        let(:execute) { false }

        it 'uses the autogenerated filename with timestamp' do
          run_rake_task
          puts Dir.pwd
          stdout_str, _status = Open3.capture2('tree')
          puts stdout_str

          expect(Dir['./db/migrate/*.rb']).not_to be_empty
        end
      end
    end
  end

  describe 'db:seed' do
    subject { 'db:seed' }
    context 'when a seed file exists' do
      before { FileUtils.touch 'db/seeds.rb' }
      it_behaves_like 'Rake task executes successfully' do
        let(:execute) { true }
      end
    end
  end

  ['db:create', 'db:migrate',
   'db:migrate:redo', 'db:migrate:reset']. each do |task_name|
    describe task_name do
      subject { task_name }

      include_context 'Rake task executes successfully' do
        let(:execute) { true }
      end
    end
  end
end
