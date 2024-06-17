require 'bundler/setup'
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
    session[:success] = 'Success! The business has been created.'
    redirect "/biz/#{uuid}"
  end
end

def error_for_biz_name(biz_name)
  'Name must be between 1 and 25 characters.' unless (1..25).cover? biz_name.size
end

get '/biz/retrieve' do
  uuid = params[:uuid]

  if @storage.valid_business?(uuid)
    redirect "/biz/#{uuid}"
  else
    session[:error] = 'Business not found! Please check your Unique ID and try again.'
    redirect '/'
  end
end

get '/biz/:uuid' do
  uuid = params[:uuid]

  if @storage.valid_business?(uuid)
    @business = @storage.load_business(uuid)
    @users = @business.users
    @biz_link = request.url

    erb :biz
  else
    session[:error] = 'Business not found! Please check your Unique ID and try again.'
    redirect '/'
  end
end

# New user form
get '/biz/:uuid/users/new' do
  erb :new_user
end

def error_for_user_params(params)
  if !(1..25).cover? params[:name].size
    'User name must be between 1 and 25 characters.'
  elsif !(1..250).cover? params[:bio].size
    'User bio must be between 1 and 250 characters.'
  elsif !(1..25).cover?(params[:love_phrase].size) || !(1..25).cover?(params[:hate_phrase].size)
    'Love and hate answers must be between 1 and 25 characters.'
  elsif [params[:need].size, params[:motivation].size, params[:challenge].size].all? { |p| !(1..100).cover? p }
    'Need, motivation, and challenge answers must be between 1 and 100 characters.'
  end
end

# Create new user
post '/biz/:uuid/users' do
  uuid = params[:uuid]
  user_params = { name: params[:name], age: params[:age],
                  bio: params[:bio], love_phrase: params[:love_phrase],
                  hate_phrase: params[:hate_phrase], need: params[:need],
                  motivation: params[:motivation], challenge: params[:challenge] }

  # error = nil
  error = error_for_user_params(user_params)
  if error
    session[:error] = error
    erb :new_user
  else
    @storage.create_new_user(uuid, user_params)
    session[:success] = 'Success! The user has been created.'
    redirect "/biz/#{uuid}"
  end
end

post '/biz/:uuid/users/:id/destroy' do
  uuid = params[:uuid]
  biz_id = params[:biz_id]
  user_id = params[:id]

  @storage.delete_user_from_biz(user_id, biz_id)
  session[:success] = 'The user has been deleted.'
  redirect "/biz/#{uuid}"
end

# Edit an existing user profile
get '/biz/:uuid/users/:id/edit' do
  @user_id = params['id']
  @uuid = params['uuid']
  @user = @storage.load_user(@user_id)

  erb :edit_user
end

# Update an existing user profile
post '/biz/:uuid/users/:id' do
  uuid = params['uuid']
  user_params = { id: params['id'], name: params[:name], age: params[:age],
                  bio: params[:bio], love_phrase: params[:love_phrase],
                  hate_phrase: params[:hate_phrase], need: params[:need],
                  motivation: params[:motivation], challenge: params[:challenge] }

  @storage.update_user(uuid, user_params)
  session[:success] = 'Success! The user has been updated.'
  redirect "/biz/#{uuid}"
end
