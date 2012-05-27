# -*- coding:utf-8; mode:ruby; -*-

require 'logger'

module Rbindkeys

  class LogUtils

    DEFAULT_LOG_OUTPUT = STDOUT
    DEFAULT_FORMAT = :simple
    DEFAULT_LEVEL = Logger::INFO
    @@output = DEFAULT_LOG_OUTPUT
    @@format = DEFAULT_FORMAT
    @@level = DEFAULT_LEVEL

    class << self

      def get_logger progname
        logger = Logger.new @@output

        logger.progname = progname
        logger.level = @@level
        set_formatter logger

        logger
      end

      def set_formatter logger
        case @@format
        when :simple
          logger.formatter = proc do |sev, date, prog, msg|
            "#{msg}\n"
          end
        when :default
        else
          l = Logger.new STDERR
          l.fatal "unknown logger format"
          exit false
        end
      end

      # setter and reader methods for the class variables
      [:output, :format, :level].each do |name|
        eval "def #{name}; @@#{name} end"
        eval "def #{name}= o; @@#{name} = o end"
      end

    end
  end

end
