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
      # (default: :observe)
      @@cmd = :observe
      def cmd; @@cmd end

      # a location of a config file (default: "~/.rbindkeys.rb")
      @@config = "#{ENV['HOME']}/.rbindkeys.rb"
      def config; @@config end

      @@usage = SUMMARY

      def main args
        begin
          parse_opt args
        rescue OptionParser::ParseError => e
          puts "ERROR #{e.to_s}"
          err
        end

        method(@@cmd).call(args)
      end

      def err code=1
        puts @@usage
        exit code
      end

      def parse_opt args
        opt = OptionParser.new <<BANNER
#{SUMMARY}
Usage: sudo #{$0} [--config file] #{EVDEVS}
   or: sudo #{$0} --evdev-list
BANNER
        opt.version = VERSION
        opt.on '-l', '--evdev-list', 'a list of event devices' do
          @@cmd = :ls
        end
        opt.on '-c VAL', '--config VAL', 'specifying your configure file' do |v|
          @@config = v
        end
        opt.on '-e', '--print-example', 'print an example config' do |v|
          @@cmd = :print_example
        end

        opt.parse! args

        @@usage = opt.help
      end

      def observe args
        if args.length != 1
          puts 'ERROR invalid arguments'
          err
        end
        evdev = args.first
        Observer.new(@@config, evdev).start
      end

      def ls args
        require 'revdev'
        Dir::glob(EVDEVS).sort do |a,b|
          am = a.match(/[0-9]+$/)
          bm = b.match(/[0-9]+$/)
          ai = am[0] ? am[0].to_i : 0
          bi = bm[0] ? bm[0].to_i : 0
          ai <=> bi
        end.each do |f|
          begin
            e = Revdev::EventDevice.new f
            puts "#{f}:	#{e.device_name} (#{e.device_id.hr_bustype})"
          rescue => ex
            puts ex
          end
        end
      end

      def print_example args
        dir = File.dirname File.expand_path __FILE__
        dir = File.expand_path File.join dir, '..', '..', 'sample'
        file = File.join dir, 'emacs.rb'
        IO.foreach file do |line|
          puts "# #{line}"
        end
      end

    end
  end # of class Runner
end
