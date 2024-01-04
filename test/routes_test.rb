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

    # Sample Data
    user_params = { name: 'Test Name', age: '25-34',
                    bio: 'Test Bio', love: 'Love Phrase',
                    hate: 'Hate Phrase', need: 'Test Need',
                    motivation: 'Test Motivation', challenge: 'Test Challenge' }
    uuid = '3eaca621-0455-413a-b36b-63c8f1cfbfc3'

    @db.create_new_biz(uuid, 'Test Biz')
    @db.create_new_user(uuid, user_params)
    @business = @db.load_business(uuid)
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
    get last_response['Location']

    assert_includes last_response.body, 'The business has been created.'
  end

  def test_retrieve_business
    get '/biz/retrieve', { uuid: '3eaca621-0455-413a-b36b-63c8f1cfbfc3' }

    assert_equal 302, last_response.status
    get last_response['Location']

    assert_includes last_response.body, '<p>Business name:'
  end

  def test_business_not_found
    get '/biz/invalid-uuid'

    assert_equal 302, last_response.status

    get last_response['Location']
    assert_includes last_response.body, 'Business not found'
  end

  def test_delete_user
    post '/biz/3eaca621-0455-413a-b36b-63c8f1cfbfc3/users/1/destroy'

    assert_equal 302, last_response.status

    get last_response['Location']
    assert_includes last_response.body, 'The user has been deleted.'
  end
end
