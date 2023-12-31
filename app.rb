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

get '/biz/:uuid' do
  uuid = params[:uuid]
  @company = @storage.load_company(uuid)

  erb :biz
end
