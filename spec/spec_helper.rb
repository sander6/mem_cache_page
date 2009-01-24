ENV['RAILS_ENV'] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../../../../config/environment")
require 'spec'
require 'spec/rails'
require 'mocha'

Spec::Runner.configure do |config|
  config.mock_with :mocha
end