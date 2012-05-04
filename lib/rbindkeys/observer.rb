# -*- coding:utf-8; mode:ruby; -*-

require "revdev"

module Rbindkeys

  # main event loop class
  class Observer
    include Revdev

    LOG = LogUtils.get_logger name

    VIRTUAL_DEVICE_NAME = "rbindkyes"

    attr_reader :device
    attr_reader :virtual
    attr_reader :event_handler
    attr_reader :config_file

    def initialize config_name, device_location
      @device = Device.new device_location
      @virtual = VirtualDevice.new
      operator = DeviceOperator.new @device, @virtual
      @event_handler = KeyEventHandler.new operator
      @config_file = config_name
    end

    # main loop
    def start
      @device.grab
      @virtual.create VIRTUAL_DEVICE_NAME #, @device.device_id

      @event_handler.load_config @config_file

      @event_handler.bind_resolver.tree.each do |k,v|
        puts "#{k} => #{v.inspect}"
      end

      trap :INT, method(:destroy)
      trap :TERM, method(:destroy)

      @device.listen do |event|
        begin
          if event.type != Revdev::EV_KEY
            @virtual.write_input_event event
          else
            @event_handler.handle event
          end
        rescue => e
          LOG.error e
        end
      end

    end

    def destroy *args
      begin
        LOG.info "try device.ungrab"
        @device.ungrab
        LOG.info "success"
      rescue => e
        LOG.error e
      end

      begin
        LOG.info "try virtural.destroy"
        @virtual.destroy
        LOG.info "success"
      rescue => e
        LOG.error e
      end

      exit true
    end

  end # of class

end # of module Rbindkeys
