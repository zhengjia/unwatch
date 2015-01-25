unwatch
-------
unwatch filters your starred repos based on last updated date. You can more easily unstar an outdated repo.

Note: This app actually **unstar** your repos, instead of **unwatch**. The repo was named before github add the "star" functionality. The repo should be changed to unstar to avoid confusion.

Updates:  Due to [high demand](https://twitter.com/danieljohngrant/status/553099594293608448), unwatch is made available again.

demo
----
A demo is at [http://unwatch.heroku.com](http://unwatch.heroku.com). If you get an error when accessing the demo, it's likely because unwatch tries to load too many repositories and reaches Heroku's a 30 seconds execution limit. Please try running unwatch locally.

screenshot
----------
![unwatch](https://github.com/zhengjia/unwatch/raw/master/screenshot/screenshot1.png "unwatch")

Currently github's interface of your starred repository is not very user-friendly. If you starred a lot of repositories and don't remember what the funny names are about, you have to visit individual repository to find out.

unwatch provides a simple interface to show the descriptions of your starred repositories and filter them based on last updated date.

development setup
-----------------
1. It's tested against ruby 2.2.
2. git clone https://github.com/zhengjia/unwatch.git
3. Register unwatch at https://github.com/settings/applications. You can name it unwatch-development; the url is a local ip like http://127.0.0.1:9292; callback is http://127.0.0.1:9292/auth/github/callback;
4. Copy oauth_example.yml to oauth.yml. Add you development client_id and secret obtained from step 3.
5. bundle
6. run test: ruby -Itest test/unwatch.rb
7. rackup

production setup
----------------
1. Register unwatch at https://github.com/settings/applications/
2. Set the environment variable ENV['RACK_ENV'] to 'production'.
3. Set the oauth credentials obtained from step 1 in ENV['client_id'] and ENV['secret'].

heroku deploy
-------------
heroku config:set client_id=XXX secret=XXX RACK_ENV=production

