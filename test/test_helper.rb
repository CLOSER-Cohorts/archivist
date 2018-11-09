require 'simplecov'
SimpleCov.start

require 'coveralls'

Coveralls.wear!

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'devise'
ActiveRecord::Migration.maintain_test_schema!

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
end

class ActionController::TestCase
  include Devise::Test::ControllerHelpers
end

class ControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
end

def time_diff_milli(start, finish)
  puts "Time to complete -> #{(finish - start) * 1000.0} milliseconds"
end

def file_data(name)
  File.read(Rails.root.to_s + "/test/fixtures/files/#{name}")
end
