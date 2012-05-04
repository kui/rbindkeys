# -*- coding:utf-8; mode:ruby; -*-

require 'logger'

module Rbindkeys

  class LogUtils

    DEFAULT_LOG_OUTPUT = STDOUT
    DEFAULT_FORMAT = :simple
    @@format = DEFAULT_FORMAT

    class << self

      def get_logger progname
        logger = Logger.new DEFAULT_LOG_OUTPUT
        logger.progname = progname
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
    end

  end

end
