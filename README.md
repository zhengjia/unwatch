unwatch
-------
unwatch filters your watched repository based on the date of last push. 

screenshot
----------
![unwatch](https://github.com/zhengjia/unwatch/raw/master/screenshot/screenshot1.png "unwatch")

Currently the github interface showing your watched repository is not very user friendly. If you are watching a lot of repository and don't remember what the funny names are about, you have to visit the repository to figure out.

unwatch provides a simple interface to show the descriptions of your watched repositories and filter based on a given last push date, so you can more easily unwatch an outdated repository that you follow impulsively.

unwatch is built with Sinatra.

development setup
-----------------
1. git clone git://github.com/zhengjia/unwatch.git
2. Register unwatch at https://github.com/account/applications/. You can name it unwatch-development; the url is a local ip like http://127.0.0.1:9292; callback is http://127.0.0.1:9292/auth/github/callback;
3. Copy oauth_example.yml to oauth.yml. Add you development client_id and secret obtained from step 2.
4. run test: ruby -Itest test/unwatch.rb
5. rackup

production setup
----------------
1. Register unwatch at https://github.com/account/applications/
2. Set the environment variable ENV['RACK_ENV'] to 'production'. 
3. Set the oauth credentials obtained from step 1 in ENV['client_id'] and ENV['secret'].
