require 'simplecov'
SimpleCov.start

require 'coveralls'

Coveralls.wear!

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'minitest/spec'
require 'devise'
ActiveRecord::Migration.maintain_test_schema!

class ActiveSupport::TestCase
  def self.ordered_fixtures(suffix: [])
    fixture_files = Dir.entries(Rails.root + 'test/fixtures').select{|file| file =~ /\.yml/}.map{|file| file.gsub('.yml','').to_sym}
    if suffix
      fixture_files = fixture_files - suffix
      fixture_files = fixture_files + suffix
    end
    fixture_files
  end
  fixtures *ordered_fixtures(suffix: [:cc_questions])

  # Add more helper methods to be used by all tests here...
  extend MiniTest::Spec::DSL

  register_spec_type(self) do |desc|
    desc < ActiveRecord::Base if desc.is_a?(Class)
  end
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
