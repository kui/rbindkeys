# -*- coding:utf-8; mode:ruby; -*-

require "revdev"

module Rbindkeys

  # main event loop class
  class Observer
    include Revdev
    attr_reader :device, :config_file, :pressed_keys, :key_binds, :verbose

    # key binds proccessed before main key binds processing
    attr_reader :pre_key_binds

    VIRTUAL_DEVICE_NAME = "rbindkyes"

    def initialize config_name, device_location
      @device = Device.new device_location
      @virtual = VirtualDevice.new
      @config_file = config_name
      @pressed_keys = {}
      @key_binds = {}
      @pre_key_binds = {}
      @verbose = true
    end

    # main loop
    def start
      @device.grab
      @virtual.create VIRTUAL_DEVICE_NAME, @device.device_id

      load_config

      trap :INT, method(:destroy)
      trap :TERM, method(:destroy)

      @device.listen do |event|
        begin
          if event.type != Revdev::EV_KEY
            @virtual.write_input_event event
          else
            puts "read	#{event.hr_code}:#{event.value==1?'pressed':'released'} (#{pressed_keys.keys.join(', ')})" if @verbose
            if resolve(event) == true
              @virtual.write_input_event event
            end

            if event.value == 1
              @pressed_keys[event.code] = true
            elsif event.value == 0
              if @pressed_keys.delete(event.code).nil?
                STDERR.puts "#{event.code} does not exists on @pressed_keys"
              end
            end
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
      @key_binds.each do |k,v|
        puts "#{k} \t=>#{v}"
      end if @verbose
    end

    def destroy
      begin
        @device.ungrab
        puts "success device.ungrab" if @verbose
      rescue => e
        puts "#{e.class}: #{e.to_s}"
        puts e.backtrace.map{|s| "\t"+s.to_s+"\n"}
      end

      begin
        @virtual.destroy
        puts "success virtural.destroy" if @verbose
      rescue => e
        puts "#{e.class}: #{e.to_s}"
        puts e.backtrace.map{|s| "\t"+s.to_s+"\n"}
      end

      exit true
    end

    def resolve event
      event.code = (@pre_key_binds[event.code] or event.code)
      r = @key_binds[event.code]
      if not r.nil?
        r.call event, self
      else
        true
      end
    end

    # entring key binds proccessed before processing main key binds
    # pre_bind_key cannot use combination key inputs/outputs
    def pre_bind_key input, output
      begin
        input = parse_code input, 2
        output = parse_code input, 2
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

      @key_binds[input] = output
    end

    def bind_event input, &block
      @key_binds[input] = block
    end

    # send a press key event
    def press_key code
      send_key code, 1
    end

    # send a release key event
    def release_key code
      send_key code, 0
    end

    # send a key event
    def send_key code, state
      code = parse_code code
      ie = InputEvent.new nil, EV_LED, code, state
      @virtual.write_input_event ie
      puts "write\t#{ie.hr_code or ie.code}:#{ie.value==1?'pressed':'released'}" if @verbose
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
  end

end # of module Rbindkeys
