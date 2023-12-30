require 'sinatra'
require 'sinatra/content_for'
require 'tilt/erubis'

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

get '/' do
  erb :home
end
