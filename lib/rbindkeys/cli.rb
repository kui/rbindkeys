# -*- coding:utf-8; mode:ruby; -*-

module Rbindkeys

  SUMMARY = 'key remapper for Linux which is configured in ruby'

  # a class is executed by bin/rbindkeys
  class CLI
    class << self
      require 'optparse'

      @@cmd = 'observe'
      @@config = '~/.rbindkey.rb'

      def main

        begin
          parse_opt
        rescue OptionParser::ParseError => e
          puts e
          err
        end

        if ARGV.length != 2
          err
        end

        Observer.new
      end

      def err code=1
        exit code
      end

      def parse_opt
        opt = OptionParser.new
        opt.version = VERSION
        opt.
        opt.on '-ls', '--evdev-list', 'a list of event devices' do
          @@cmd = 'ls'
        end
        opt.on '-c VAL', '--config VAL', 'specifying your configure file' do |v|
          @@config = v
        end
        opt.parse! ARGV
      end
    end
  end # of class Runner
end
