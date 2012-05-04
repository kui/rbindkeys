# -*- coding:utf-8; mode:ruby; -*-

require 'revdev'

module Rbindkeys

  # device operations like send key event, send LED event, etc.
  class DeviceOperator

    LOG = LogUtils.get_logger name

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

    def release_key code
      send_key code, 0
    end
    def press_key code
      send_key code, 1
    end
    def pressing_key code
      send_key code, 2
    end

    def send_key code, state
      send_event Revdev::EV_KEY, code, state
    end

    def send_event *args
      event =
        case args.length
        when 1; args[0]
        when 3
          @cache_input_event ||= Revdev::InputEvent.new nil, 0, 0, 0
          @cache_input_event.type = args[0]
          @cache_input_event.code = args[1]
          @cache_input_event.value = args[2]
          @cache_input_event
        else raise ArgumentError, "expect a InputEvent or 3 Fixnums (type, code, state)"
        end

      update_pressed_key_set event
      size = @virtual.write_input_event event
      LOG.info "write\t#{KeyEventHandler.get_state_by_value event} "+
        "#{event.hr_code}(#{event.code})" if LOG.info?
    end

    def update_pressed_key_set event
      if event.type == Revdev::EV_KEY
        case event.value
        when 0; @pressed_key_set.delete event.code
        when 1; @pressed_key_set << event.code
        when 2
        else raise UnknownKeyValue, "expect 0, 1 or 2"
        end
      end
    end

  end

end
