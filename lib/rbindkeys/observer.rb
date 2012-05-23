# -*- coding:utf-8; mode:ruby; -*-

require "thread"
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
      @event_handler_mutex = Mutex.new
      @config_file = config_name
      @started = false
      @window_observer = ActiveWindowX::EventListener.new
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

      start_window_observation

      @started = true
      @device.listen do |event|
        begin
          if event.type != Revdev::EV_KEY
            @virtual.write_input_event event
          else
            @event_handler_mutex.synchronize do
              @event_handler.handle event
            end
          end
        rescue => e
          LOG.error e
        end
      end
    end

    def start_window_observation
      Thread.new do
        @window_observer.start do |e|
          @event_handler_mutex.synchronize do
            @event_handler.active_window_changed e.window
          end
        end
      end.abort_on_exception = true
    end

    def destroy *args
      if not @started
        LOG.error 'did not start to observe'
        return
      end

      begin
        LOG.info "try @device.ungrab"
        @device.ungrab
        LOG.info "=> success"
      rescue => e
        LOG.error e
      end

      begin
        LOG.info "try @virtural.destroy"
        @virtual.destroy
        LOG.info "=> success"
      rescue => e
        LOG.error e
      end

      begin
        LOG.info "try @window_observer.destory"
        @window_observer.destory
        LOG.info "=> success"
      rescue => e
        LOG.error e
      end

      exit true
    end

  end # of class

end # of module Rbindkeys
