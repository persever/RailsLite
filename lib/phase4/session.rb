require 'json'
require 'webrick'

module Phase4
  class Session
    # find the cookie for this app
    # deserialize the cookie into a hash
    def initialize(req)
      @req = req
      app_cookie = req.cookies.find { |cookie| cookie.name == "_rails_lite_app" }
      if app_cookie
        @app_cookie = JSON.parse(app_cookie.value)
      else
        @app_cookie = {}
      end
    end

    def [](key)
      @app_cookie[key]
    end

    def []=(key, val)
      @app_cookie[key] = val
    end

    # serialize the hash into json and save in a cookie
    # add to the responses cookies
    def store_session(res)
      res.cookies << WEBrick::Cookie.new("_rails_lite_app", @app_cookie.to_json)
    end
  end
end
