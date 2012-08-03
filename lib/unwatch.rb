ENV['RACK_ENV'] ||= 'development'

require 'sinatra/base'
require 'oauth2'
require 'json'
require 'yaml'

if ENV['RACK_ENV'] == 'development'
  require 'pry'
end  

class Unwatch < Sinatra::Base
  
  set :views, [File.expand_path('../views', File.dirname(__FILE__))]
  
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
    set :public_folder, 'public'
    set :session_secret, "unwatch" # shotgun bug
  end
  
  helpers do
    def client
      if !session[:access_token]
        @auth_client ||= OAuth2::Client.new(settings.client_id, settings.secret, :site => 'https://github.com', :authorize_url => '/login/oauth/authorize', :token_url => '/login/oauth/access_token')
      else
        @api_client ||= OAuth2::Client.new(settings.client_id, settings.secret, :site => 'https://api.github.com')
      end    
    end
    
    def access_token
      @access_token ||= OAuth2::AccessToken.new(client, session[:access_token])
    end
    
    def send_request(uri, method='get')
      begin
        oauth_response = access_token.send(method, uri, headers)
        JSON.parse(oauth_response.body) unless oauth_response.body.empty?
      rescue OAuth2::Error
        session[:access_token] = nil
        status 503
        halt %(<p>#{$!}</p><p><a href="/auth/github">Retry</a></p>)
      end
    end
    
    def get_init_data
      @watched = []
      @username = send_request('/user')['login']
      @watched = walk_repos
    end
    
    def walk_repos
      page = 1
      results = []
      res = []
      begin
        res = send_request("/users/#{@username}/watched?page=#{page}")
        results.concat res
        page = page + 1
      end while !res.empty?
      results
    end
    
    def headers
      {'Accept' => 'application/vnd.github.3+json'}
    end
    
    def unwatch_repo(username, repo)
      send_request("/user/watched/#{username}/#{repo}", 'delete')
    end
    
    def redirect_uri(path = '/auth/github/callback', query = nil)
      uri = URI.parse(request.url)
      uri.path  = path
      uri.query = query
      uri.to_s
    end
    
    def get_token(code)
      client.auth_code.get_token(code, :redirect_uri => redirect_uri).token
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
    url = client.auth_code.authorize_url(:redirect_uri => redirect_uri, :scope => 'public_repo')
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