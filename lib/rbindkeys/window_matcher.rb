# -*- coding:utf-8; mode:ruby; -*-
#
# matcher for windows to use the app_class(app_name), title of the windows
#

module Rbindkeys
  class WindowMatcher

    attr_reader :app_name, :title

    def initialize h
      @app_name = (h[:class] or h[:app_name] or h[:app_class])
      @title = (h[:title] or h[:name])

      if not @app_name.nil? and not @title.nil?
        raise ArgumentError, 'expect to be given :class, :app_name,'+
          ' :app_class, :title or :name '
      end
    end

    def match? app_name, title
      (@app_name.nil? or match_app?(app_name)) and
        (@title.nil? or match_title?(title))
    end

    def match_app? app_name
      app_name and app_name.match @app_name
    end

    def match_title? title
      title and title.match @title
    end

  end
end
