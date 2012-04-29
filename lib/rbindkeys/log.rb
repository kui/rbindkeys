# -*- coding:utf-8; mode:ruby; -*-

require 'logger'

module Rbindkeys

  class LogUtils

    def get_logger progname
      logger = Logger.new DEFAULT_LOG_OUTPUT
      logger.progname = prog
      logger
    end

  end

end
