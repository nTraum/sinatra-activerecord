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

  gem.metadata['homepage_uri']    = gem.homepage
  gem.metadata['source_code_uri'] = gem.homepage
  gem.metadata['changelog_uri']   = 'https://github.com/ntraum/sinatra-activerecord6/CHANGELOG.md'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gem.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  gem.require_paths = ['lib']

  gem.required_ruby_version = '>= 2.4.0'

  gem.add_dependency 'activerecord', '>= 6.0'
  gem.add_dependency 'activesupport', '>= 6.0'
  gem.add_dependency 'rake'
  gem.add_dependency 'sinatra', '>= 2.0'
end
