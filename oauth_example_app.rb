require 'sinatra/base'
require 'rubygems'
require 'json'
require 'dailymile'
require 'erb'

Dailymile::Client.set_client_credentials ENV['CLIENT_ID'], ENV['CLIENT_SECRET']

class OauthExampleApp < Sinatra::Base
  set :sessions, true

  get '/' do
    redirect '/authorize' unless session[:access_token]
    
    @user = client.get '/people/me'
    
    erb :index
  end
  
  get '/authorize' do
    redirect Dailymile::Client.oauth_client.web_server.authorize_url(:redirect_uri => redirect_uri, :response_type => 'code')
  end
  
  get '/callback' do
    begin
      access_token = Dailymile::Client.oauth_client.web_server.get_access_token(params[:code], :redirect_uri => redirect_uri, :grant_type => 'authorization_code')
      session[:access_token] = access_token.token
      
      redirect '/'
    rescue
      %{Failed to retrieve access. <a href="/">Try again</a>}
    end
  end
  
private
  
  def redirect_uri
    uri = URI.parse(request.url)
    "#{uri.scheme}://#{uri.host}:#{uri.port}/callback"
  end
  
  def client
    @client ||= Dailymile::Client.new(session[:access_token])
  end
  
end

OauthExampleApp.run!