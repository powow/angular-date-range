require 'rspec/autorun'

require 'capybara/poltergeist'
require 'capybara/angular'
require 'capybara/rspec'
require 'active_support/all'

require_relative '../example/app'

RSpec.configure do |config|
  config.include Capybara::Angular::DSL
end

Capybara.app = ExampleApp
Capybara.javascript_driver = :poltergeist

Capybara.add_selector(:model) do
  css { |model| "*[ng-model='#{model}']" }
end
