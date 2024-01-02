require 'sinatra'
require 'sinatra/content_for'
require 'tilt/erubis'
require 'securerandom'

require_relative 'lib/database_connection'
require_relative 'lib/helpers'

configure do
  enable :sessions
  set :session_secret, SecureRandom.hex(32)
  set :erb, escape_html: true
end

configure(:development) do
  require 'sinatra/reloader'
  also_reload 'lib/*.rb'
  set :server, %w[webrick puma]
end

before do
  @storage = DatabaseConnection.new(logger)
end

after do
  @storage.disconnect
end

get '/' do
  erb :home
end

# Create a new business
post '/biz' do
  biz_name = params[:biz_name].strip

  error = error_for_biz_name(biz_name)
  if error
    session[:error] = error
    erb :home
  else
    uuid = SecureRandom.uuid
    @storage.create_new_biz(uuid, biz_name)
    session[:success] = 'The list has been created.'
    redirect "/biz/#{uuid}"
  end
end

def error_for_biz_name(biz_name)
  'Name must be between 1 and 25 characters.' unless (1..25).cover? biz_name.size
end

get '/biz/retrieve' do
  uuid = params[:uuid]
  redirect "/biz/#{uuid}"
end

get '/biz/:uuid' do
  uuid = params[:uuid]
  @business = @storage.load_business(uuid)
  @users = @business.users
  @biz_link = request.url

  erb :biz
end

# New user form
get '/biz/:uuid/users/new' do
  erb :new_user
end

# Create new user
post '/biz/:uuid/users' do
  uuid = params[:uuid]
  user_params = { name: params[:name], age: params[:age],
                  bio: params[:bio], love: params[:love_phrase],
                  hate: params[:hate_phrase], need: params[:motivation],
                  motivation: params[:motivation], challenge: params[:challenge] }

  error = nil
  # error = error_for_user_params(user_params)
  if error
    session[:error] = error
    erb :home
  else
    @storage.create_new_user(uuid, user_params)
    session[:success] = 'The user has been created.'
    redirect "/biz/#{uuid}"
  end
end
