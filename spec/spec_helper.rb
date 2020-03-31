require 'pry'
require 'sinatra/activerecord'

RSpec.configure do |config|
  config.disable_monkey_patching!

  config.before { FileUtils.mkdir_p("tmp") }
  config.after  { FileUtils.rm_rf("tmp") }
end
