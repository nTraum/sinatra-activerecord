# frozen_string_literal: true

require 'rake'

load 'active_record/railties/databases.rake'

require "sinatra/activerecord"
require "sinatra/activerecord/rake/activerecord_#{ActiveRecord::VERSION::MAJOR}"

load 'sinatra/activerecord/tasks.rake'
