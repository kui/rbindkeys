# -*- coding:utf-8; mode:ruby; -*-

require "thread"
require "revdev"

module Rbindkeys

  # main event loop class
  class Observer
    include Revdev

    LOG = LogUtils.get_logger name
    VIRTUAL_DEVICE_NAME = "rbindkyes"
    DEFAULT_TIMEOUT = 0.5

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
      @started = false
      @window_observer = ActiveWindowX::EventListener.new
      @timeout = DEFAULT_TIMEOUT
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

      active_window = @window_observer.active_window
      @event_handler.active_window_changed active_window if active_window

      # start main loop
      @started = true
      while true
        ios = select_ios
        if ios.nil?
          # select timeout
          # no op
          next
        end

        if LOG.debug?
          LOG.debug ""
          LOG.debug "select => #{ios.inspect}"
        end

        ios.each do |io|
          case io
          when @window_observer.connection then handle_x_event
          when @device.file then handle_device_event
          else LOG.error "unknown IO #{io.inspect}"
          end
        end
      end
    end

    def select_ios
      if @window_observer.pending_events_num != 0
        [@window_observer.connection]
      else
        ios = select [@window_observer.connection, @device.file], nil, nil, @timeout
        if ios.nil?
          nil
        else
          ios.first
        end
      end
    end

    def handle_x_event
      event = @window_observer.listen_with_no_select
      return if event.nil? or event.window.nil?

      @event_handler.active_window_changed event.window
    end

    def handle_device_event
      event = @device.read_input_event

      if event.type != Revdev::EV_KEY
        @virtual.write_input_event event
      else
        @event_handler.handle event
      end
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
        @window_observer.destroy
        LOG.info "=> success"
      rescue => e
        LOG.error e
      end

      exit true
    end

  end # of class

end # of module Rbindkeys
