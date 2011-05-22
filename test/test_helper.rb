ENV['RACK_ENV'] = 'test'
$:.unshift File.expand_path('../lib', File.dirname(__FILE__))
require 'sinatra/base'
require 'test/unit'
require 'rack/test'
require 'mocha'

module Rack::Test
  DEFAULT_HOST = "unwatch.heroku.com"
end

Test::Unit::TestCase.class_eval do
  include Rack::Test::Methods
end

def app
  @app ||= Unwatch
end

def mock_app(base=Sinatra::Base, &block)
  @app = Sinatra.new(base, &block)
end

def fixture_watched
  {"repositories"=>[{"has_issues"=>true, "owner"=>"mojombo", "pushed_at"=>"2011/05/07 19:32:33 -0700", "watchers"=>952, "has_downloads"=>true, "forks"=>130, "description"=>"Grit gives you object oriented read/write access to Git repositories via Ruby.", "fork"=>false, "size"=>4498, "name"=>"grit", "has_wiki"=>true, "language"=>"Ruby", "url"=>"https://github.com/mojombo/grit", "private"=>false, "open_issues"=>43, "homepage"=>"http://grit.rubyforge.org/", "created_at"=>"2007/10/29 07:37:16 -0700"}, {"has_issues"=>true, "owner"=>"evanphx", "pushed_at"=>"2011/05/19 21:27:31 -0700", "watchers"=>1002, "has_downloads"=>true, "forks"=>160, "description"=>"Rubinius, the Ruby VM", "fork"=>false, "size"=>15384, "name"=>"rubinius", "has_wiki"=>true, "language"=>"Ruby", "url"=>"https://github.com/evanphx/rubinius", "private"=>false, "open_issues"=>37, "master_branch"=>"master", "homepage"=>"http://rubini.us", "created_at"=>"2008/01/12 08:46:52 -0800"} ]}
end

require 'unwatch'