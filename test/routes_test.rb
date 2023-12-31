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

  def session
    last_request.env['rack.session']
  end

  def setup
    @db = DatabaseConnection.new
    @db.delete_all_data
  end

  def teardown
    @db.delete_all_data
  end

  def test_index
    get '/'
    assert_equal 200, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_includes last_response.body, '<p>To get started, create your business'
  end

  def test_create_business
    post '/biz', { biz_name: 'Test Business' }

    assert_equal 302, last_response.status
    assert_equal 'The list has been created.', session[:success]
  end
end
