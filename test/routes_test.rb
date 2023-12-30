ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'rack/test'
require 'minitest/reporters'
Minitest::Reporters.use!

require_relative '../app'

class RoutesTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end
end
