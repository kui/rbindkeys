# -*- coding:utf-8; mode:ruby; -*-

require 'logger'

module Rbindkeys

  class LogUtils

    DEFAULT_LOG_OUTPUT = STDOUT

    def LogUtils.get_logger progname
      logger = Logger.new DEFAULT_LOG_OUTPUT
      logger.progname = progname
      logger
    end

  end

end
