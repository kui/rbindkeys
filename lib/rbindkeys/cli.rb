# -*- coding:utf-8; mode:ruby; -*-

module Rbindkeys

  SUMMARY = 'key remapper for Linux which is configured in ruby'

  # a class is executed by bin/rbindkeys
  class CLI

    EVDEVS = '/dev/input/event*'

    class << self
      require 'optparse'

      # if @@cmd == :observe then CLI excecute to observe a given event device
      # else if @@cmd == :ls then CLI list event devices
      @@cmd = :observe
      def cmd; @@cmd end

      # a location of a config file (default: "~/.rbindkey.rb")
      @@config = '~/.rbindkey.rb'
      def config; @@config end

      def main
        begin
          opt = parse_opt
        rescue OptionParser::ParseError => e
          puts "ERROR: #{e.to_s}"
          err
        end

        method(@@cmd).call
      end

      def err code=1
        exit code
      end

      def parse_opt
        opt = OptionParser.new <<BANNER
#{SUMMARY}
Usage: #{$0} [--config file] #{EVDEVS}
   or: #{$0} --evdev-list
BANNER
        opt.version = VERSION
        opt.on '-ls', '--evdev-list', 'a list of event devices' do
          @@cmd = :ls
        end
        opt.on '-c VAL', '--config VAL', 'specifying your configure file' do |v|
          @@config = v
        end
        opt.parse! ARGV

        opt
      end

      def observe
        evdev = ARGV.first
        Observer.new @@config, evdev
      end

      def ls
      end

    end
  end # of class Runner
end
