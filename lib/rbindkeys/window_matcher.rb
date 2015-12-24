# -*- coding:utf-8; mode:ruby; -*-
#
# matcher for windows to use the app_class(app_name), title of the windows
#

module Rbindkeys
  class WindowMatcher

    attr_reader :app_name, :title, :app_class

    def initialize h
      @app_name = h[:app_name]
      @app_class = h[:app_class] || h[:class]
      @title = h[:title] || h[:name]

      if @app_name.nil? and @app_class.nil? and @title.nil?
        raise ArgumentError, 'expect to be given :class, :app_name,'+
          ' :app_class, :title or :name '
      end
    end

    def match? app_name, app_class, title
      (@app_name.nil? or match_app?(app_name)) and
        (@app_class.nil? or match_class?(app_class)) and
        (@title.nil? or match_title?(title))
    end

    def match_app? app_name
      app_name and app_name.match @app_name
    end

    def match_class? app_class
      app_class and app_class.match @app_class
    end

    def match_title? title
      title and title.match @title
    end

  end
end
