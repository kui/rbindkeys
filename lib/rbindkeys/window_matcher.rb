# -*- coding:utf-8; mode:ruby; -*-
#
# matcher for windows to use the app_class(app_name), title of the windows
#

module Rbindkeys
  class WindowMatcher

    def initialize h
      @app_name = (h[:class] or h[:app_name] or h[:app_class])
      @title = (h[:title] or h[:name])
    end

    def match? app_name, title
        match_app?(app_name) and match_title?(title)
    end

    def match_app? app_name
      app_name and @app_name and app_name.match @app_name
    end

    def match_title? title
      title and @title and title.match @title
    end

  end
end
