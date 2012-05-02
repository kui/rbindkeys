# -*- coding:utf-8; mode:ruby; -*-

require "rbindkeys/key_event_handler/configurer"

module Rbindkeys

  # device operations like send key event, send LED event, etc.
  class DeviceOperator

    # real event device
    attr_reader :device

    # uinput device
    attr_reader :virtural

    # key code set which was send press event but is not send release event
    attr_reader :pressed_key_set

    def initialize dev, vdev
      @device = dev
      @virtual = vdev
      @pressed_key_set = []
    end

  end

end
