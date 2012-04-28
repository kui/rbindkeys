# -*- coding:utf-8; mode:ruby; -*-

require "revdev"

module Rbindkeys

  # main event loop class
  class Observer
    include Revdev

    VIRTUAL_DEVICE_NAME = "rbindkyes"

    attr_reader :device, :config_file, :verbose

    # key binds proccessed before main key binds processing
    attr_reader :pre_key_binds

    # main key binds
    attr_reader :key_binds

    # pressed keys stored as sorted Array
    attr_reader :pressed_keys

    # pressed keys stored as sorted Array on the virtual device
    attr_reader :virtual_pressed_keys

    # active bind
    attr_reader :active_bind

    def initialize config_name, device_location
      @device = Device.new device_location
      @virtual = VirtualDevice.new
      @config_file = config_name
      @pressed_keys = []
      @key_binds = BindTree.new
      @pre_key_binds = {}
      @virtual_pressed_keys = []
      @verbose = true
    end

    # main loop
    def start
      @device.grab
      @virtual.create VIRTUAL_DEVICE_NAME #, @device.device_id

      load_config

      trap :INT, method(:destroy)
      trap :TERM, method(:destroy)

      @device.listen do |event|
        begin
          if event.type != Revdev::EV_KEY
            @virtual.write_input_event event
          else
            resolve event
          end
        rescue => e
          puts "#{e.class}: #{e.to_s}"
          puts e.backtrace.map{|s| "\t#{s.to_s}\n"}
        end
      end

    end

    def load_config
      puts "load #{@config_file}"
      code = File.read @config_file
      instance_eval code, @config_file
      p @key_binds if @verbose
    end

    def destroy *args
      begin
        puts "try device.ungrab" if @verbose
        @device.ungrab
        puts "success" if @verbose
      rescue => e
        puts "#{e.class}: #{e.to_s}"
        puts e.backtrace.map{|s| "\t"+s.to_s+"\n"}
      end

      begin
        puts "try virtural.destroy" if @verbose
        @virtual.destroy
        puts "success" if @verbose
      rescue => e
        puts "#{e.class}: #{e.to_s}"
        puts e.backtrace.map{|s| "\t"+s.to_s+"\n"}
      end

      exit true
    end

    def handle_pressed_keys event
      if event.value == 1
        @pressed_keys << event.code
      elsif event.value == 0
        if @pressed_keys.delete(event.code).nil?
          STDERR.puts "WARNING: #{event.code} does not exists on @pressed_keys"
        end
      end
    end

    def resolve event
      if @verbose
        puts "\nread\t#{get_state_by_value event}#{event.hr_code}(#{event.code})"
      end

      # handle pre_key_binds
      event.code = (@pre_key_binds[event.code] or event.code)

      @pressed_keys.sort!
      result =
        case event.value
        when 0; resolve_for_released event
        when 1; resolve_for_pressed event
        when 2; resolve_for_pressing event
        else raise UnknownKeyValueError, "expect 0, 1 or 2 as event.value(#{event.value})"
        end

      if result  == :through
        fill_gap_pressed_state
        send_event event
      end

      handle_pressed_keys event

      if @verbose
        puts "pressed_keys real:#{@pressed_keys.inspect} virtual:#{@virtual_pressed_keys.inspect}"
      end
    end

    def resolve_for_pressed event
      r = @key_binds.resolve_for_pressed_event event, @pressed_keys
      if r.kind_of? KeyBind
        r.input.clone.delete_if{|c|c==event.code}.each {|c| release_key c}
        r.output.each {|c| press_key c}
        false
      else
        r
      end
    end

    def resolve_for_released event
      r = @key_binds.resolve_for_released_event event, @pressed_keys
      if r.kind_of? Array
        if r.empty?
          @key_binds.default_value
        else
          r.each do |kb|
            kb.output.each {|c| release_key c}
            if kb.input_recovery
              kb.input.clone.delete_if{|c|c==event.code}.each{|c|press_key c}
            end
          end
          false
        end
      else
        r
      end
    end

    def resolve_for_pressing event
      r = @key_binds.resolve_for_pressing_event event, @pressed_keys
      if r.kind_of? Array
        if r.empty?
          @key_binds.default_value
        else
          r.each {|kb| kb.output.each {|c| pressing_key c}}
          false
        end
      else
        r
      end
    end

    def get_state_by_value ev
      case ev.value
      when 0; 'released '
      when 1; 'pressed  '
      when 2; 'pressing '
      end
    end

    def fill_gap_pressed_state
      return if @virtual_pressed_keys == @pressed_keys
      sub = @pressed_keys - @virtual_pressed_keys
      sub.each {|code| press_key code}
    end

    def handle_virtual_pressed_keys ev
      return if ev.type != EV_KEY
      case ev.value
      when 0; @virtual_pressed_keys.delete ev.code
      when 1; @virtual_pressed_keys << ev.code
      when 2
      else raise UnknownKeyValueError, "expect 0, 1 or 2 as ev.value(#{ev.value})"
      end
    end

    # send a press key event
    def press_key code
      send_key code, 1
    end

    # send a release key event
    def release_key code
      send_key code, 0
    end

    # send a press key event
    def pressing_key code
      send_key code, 2
    end

    # send a key event
    def send_key code, state
      code = parse_code code
      @key_ev ||= InputEvent.new nil, EV_KEY, code, state
      @key_ev.code = code
      @key_ev.value = state
      send_event @key_ev
    end

    def send_event ie
      if @verbose and ie.type == EV_KEY
        puts "write\t#{get_state_by_value ie}#{ie.hr_code}(#{ie.code})"
      end
      handle_virtual_pressed_keys ie
      @virtual.write_input_event ie
    end

    # parse and normalize to Fixnum (Array)
    def parse_code code, depth = 0
      if code.kind_of? Symbol
        code = Revdev.const_get code
      elsif code.kind_of? Array
        raise ArgumentError, "expect Array is the depth less than 2" if depth >= 2
        code.map!{|c| parse_code c, (depth+1)}
      elsif not code.kind_of? Fixnum
        raise ArgumentError, "expect Symbol / Fixnum / Array"
      end
      code
    end

    # switch on the LED of the keyboard
    def led_on code
      led code, 1
    end

    # switch off the LED of the keyboard
    def led_off code
      led code, 0
    end

    # switch on/off the LED of the keyboard
    def led code, state
      if code.kind_of? Symbol
        code = Revdev.const_get Symbol
      elsif not code.kind_of? Fixnum
        raise ArgumentError, "expect Symbol or Fixnum"
      end
      @device.write_input_event InputEvent.new nil, EV_LED, code, state
    end

    # for config

    # entring key binds proccessed before processing main key binds
    # pre_bind_key cannot use combination key inputs/outputs
    def pre_bind_key input, output
      begin
        input = parse_code input, 2
        output = parse_code output, 2
      rescue ArgumentError
        raise ArgumentError, "expect Symbol or Fixnum"
      end

      if @pre_key_binds.has_key? input
        raise ArgumentError, "1st arg (#{input}) was already entried"
      end

      @pre_key_binds[input] = output
    end

    def bind_key input, output
      input = parse_code input
      output = parse_code output

      input = [input] if input.kind_of? Fixnum
      output = [output] if output.kind_of? Fixnum

      last = input.pop
      input.sort!
      input.push last

      @key_binds.bind input, output
    end

    def bind_event input, &block # TODO implement
      # @key_binds[input] = block
    end

    # /for config

    class UnknownKeyValueError < RuntimeError; end
  end

end # of module Rbindkeys
