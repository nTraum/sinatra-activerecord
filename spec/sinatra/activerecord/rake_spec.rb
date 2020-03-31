require 'spec_helper'
require 'fileutils'

RSpec.describe "the rake tasks" do
  before do
    Class.new(Sinatra::Base) do
      register Sinatra::ActiveRecordExtension
      set :database, {adapter: "sqlite3", database: "tmp/foo.sqlite3"}
    end

    FileUtils.mkdir_p "db"
    FileUtils.touch "db/seeds.rb"

    require 'rake'
    require 'sinatra/activerecord/rake'
  end

  after do
    FileUtils.rm_rf "db"
  end

  ["db:create", "db:create_migration", "db:migrate", "db:migrate:redo", "db:reset", "db:seed"]. each do |task_name|
    describe task_name do
      subject { Rake::Task[task_name] }
      after { subject.reenable }

      it 'executes successfully' do
        ENV["NAME"] = "create_users"

        subject.invoke

        ENV.delete("NAME")
      end
    end
  end
end
