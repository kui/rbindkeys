# -*- coding:utf-8; mode:ruby; -*-

require 'revdev'

module Rbindkeys
  class Device < Revdev::EventDevice
    def release_all_key
      ie = Revdev::InputEvent.new nil, 0, 0, 0

      Revdev.constants.grep(/^KEY|^BTN/).each do |c|
        ie.type = Revdev::EV_KEY
        ie.code = Revdev.const_get c
        ie.value = 0
        write_input_event ie

        ie.type = Revdev::EV_SYN
        ie.code = 0
        write_input_event ie
      end
    end
  end
end
