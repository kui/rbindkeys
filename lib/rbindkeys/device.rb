# -*- coding:utf-8; mode:ruby; -*-

require "revdev"

module Rbindkeys

  class Device < Revdev::EventDevice

    def listen
      if not block_given?
        raise ArgumentError, "expect to give a block"
      end
      loop do
        event = read_input_event
        yield event
      end
    end

  end

end
