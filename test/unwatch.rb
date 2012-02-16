require File.expand_path('../test_helper', __FILE__)

class UnwatchTest < Test::Unit::TestCase

  def test_index_unauthorized
    get '/'
    assert last_response.ok?
  end
  
  def test_index_authorized
    get '/', {}, 'rack.session' => { :access_token => 'dummy' }
    assert_equal 302, last_response.status
    assert_equal "http://unwatch.heroku.com/list", last_response.location
  end
  
  def test_redirect_to_github_for_authentication
    get '/auth/github'
    follow_redirect!
    assert_match /https:\/\/github.com\/login\/oauth\/authorize/, last_request.url
  end
  
  def test_pass_client_id_to_github
    get '/auth/github'
    follow_redirect!
    assert_not_nil last_request.params['client_id']
    assert !last_request.params['client_id'].empty?
  end
  
  def test_pass_scope_to_github
    get '/auth/github'
    follow_redirect!
    assert_not_nil last_request.params['scope']
    assert !last_request.params['scope'].empty?
  end
  
  def test_redirect_uri
    get '/auth/github'
    follow_redirect!
    assert_equal "http://unwatch.heroku.com/auth/github/callback", last_request.params['redirect_uri']
  end

  def test_github_callback_authorized
    
    mock_app(Unwatch) do
      helpers do
        def get_token(code)
          "dummy_token"
        end
      end  
    end
    
    get '/auth/github/callback'
    assert_equal 302, last_response.status
    assert_equal "http://unwatch.heroku.com/", last_response.location
  end
  
  def test_list_unauthorized
    get '/list'
    assert_equal 302, last_response.status
    assert_equal "http://unwatch.heroku.com/", last_response.location
  end
  
  def test_list_authorized
    mock_app(Unwatch) do
      helpers do
        def get_init_data
          @username = "zhengjia"
          @watched = fixture_watched
        end
      end  
    end
    get '/list', {}, 'rack.session' => { :access_token => 'dummy' }
    assert_equal 200, last_response.status
  end
  
  def test_unwatch_repo
    mock_app(Unwatch) do
      helpers do
        def unwatch_repo(username, repo)
        end
      end  
    end
    post '/unwatch/zhengjia/unwatch'
    assert_equal 200, last_response.status
  end

end
