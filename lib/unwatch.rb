require 'sinatra/base'
require 'oauth2'
require 'json'
require 'yaml'

class Unwatch < Sinatra::Base
  
  configure do
    if production?
      set :client_id, ENV['client_id']
      set :secret, ENV['secret']
    else  
      config = YAML::load(File.open('oauth.yml'))
      set :client_id, config['development']['client_id']
      set :secret, config['development']['secret']
    end  
    enable :sessions unless test?
    set :static, true
    set :public, 'public'
    set :session_secret, "unwatch" # shotgun bug
  end
  
  helpers do
    def client
      @client ||= OAuth2::Client.new(settings.client_id, settings.secret, :site => 'https://github.com', :authorize_path => '/login/oauth/authorize', :access_token_path => '/login/oauth/access_token')
    end
    
    def access_token
      @client ||= OAuth2::AccessToken.new(client, session[:access_token])
    end
    
    def send_request(uri)
      begin
        JSON.parse(access_token.get(uri))
      # OAuth2::AccessDenied: the repository isn't watched by the user  
      rescue OAuth2::HTTPError, OAuth2::AccessDenied
        session[:access_token] = nil
        status 503
        halt %(<p>#{$!}</p><p><a href="/auth/github">Retry</a></p>)
      end
    end
    
    def get_init_data
      @username = send_request('/api/v2/json/user/show')['user']['login']
      @watched = send_request("/api/v2/json/repos/watched/#{@username}")
    end
    
    def unwatch_repo(username, repo)
      send_request("/api/v2/json/repos/unwatch/#{username}/#{repo}")
    end
    
    def redirect_uri(path = '/auth/github/callback', query = nil)
      uri = URI.parse(request.url)
      uri.path  = path
      uri.query = query
      uri.to_s
    end
    
    def get_token(code)
      client.web_server.get_access_token(code, :redirect_uri => redirect_uri).token
    end
    
    def has_access
      unless session[:access_token]
        redirect '/'
      end
    end
    
  end

  get "/" do
    if session[:access_token]
      redirect '/list'
    end  
    erb :index
  end
  
  get '/list' do
    has_access
    get_init_data
    erb :unwatch
  end
  
  post '/unwatch/:username/:repo' do
    if params[:username] && params[:repo]
      unwatch_repo(params[:username], params[:repo])
      repo_str = "#{params[:username]}/#{params[:repo]}"
      "Successfully unwatched #{repo_str}"
    else
      status 503  
      halt "Failed to unwatch #{repo_str}"
    end  
  end

  get '/auth/github' do
    url = client.web_server.authorize_url(:redirect_uri => redirect_uri, :scope => 'public_repo')
    redirect url
  end

  get '/auth/github/callback' do
    token = get_token(params[:code])
    session[:access_token] = token unless token.empty?
    if session[:access_token]
      redirect '/'
    else
      status 401
      halt %(<p>Please authorize on github.</p><p><a href="/auth/github">Retry</a></p>)
    end    
  end
  
end