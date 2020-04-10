# coding: utf-8
# frozen_string_literal: true

require_relative 'lib/sinatra/activerecord/version'

Gem::Specification.new do |gem|
  gem.name         = 'sinatra-activerecord6'
  gem.version      = Sinatra::ActiveRecord::VERSION
  gem.authors      = ['Blake Mizerany', 'Janko Marohnić', 'Philipp Preß']
  gem.email        = ['ntraum@fastmail.com']
  gem.license      = 'MIT'
  gem.homepage     = 'https://github.com/ntraum/sinatra-activerecord6'

  gem.description  = 'Extends Sinatra with ActiveRecord helpers.'
  gem.summary      = gem.description



  gem.files        = Dir['lib/**/*'] + ['README.md', 'LICENSE']
  gem.require_path = 'lib'
  gem.test_files   = gem.files.grep(%r{^(test|spec|features)/})

  gem.required_ruby_version = '>= 2.4.0'

  gem.add_dependency 'activerecord', '>= 6.0'
  gem.add_dependency 'activesupport', '>= 6.0'
  gem.add_dependency 'rake'
  gem.add_dependency 'sinatra', '>= 2.0'
end
