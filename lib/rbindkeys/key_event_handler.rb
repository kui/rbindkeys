# -*- coding:utf-8; mode:ruby; -*-

require "rbindkeys/key_event_handler/configurer"

module Rbindkeys

  # retrive key binds with key event
  class KeyEventHandler
    include Revdev

    LOG = LogUtils.get_logger name

    # device operator
    attr_reader :operator

    # defaulut key bind set which retrive key binds with a key event
    attr_reader :default_bind_resolver

    # current key bind set which retrive key binds with a key event
    attr_reader :bind_resolver

    # proccessed resolver before bind_resolver
    attr_reader :pre_bind_resolver

    # code set of pressed key on the event device
    attr_reader :pressed_key_set

    # pressed key binds
    attr_reader :active_bind_set

    def initialize device_operator
      @operator = device_operator
      @default_bind_resolver = BindResolver.new
      @bind_resolver = @default_bind_resolver
      @pre_bind_resolver = {}
      @pressed_key_set = []
      @active_bind_set = []
    end

    def load_config file
      code = File.read file
      instance_eval code, file
    end

    def handle event
      LOG.info "read\t#{KeyEventHandler.get_state_by_value event} "+
        "#{event.hr_code}(#{event.code})" if LOG.info?

      # handle pre_key_bind_set
      event.code = (@pre_bind_resolver[event.code] or event.code)

      # swich to handle event with event.value
      result =
        case event.value
        when 0; handle_release_event event
        when 1; handle_press_event event
        when 2; handle_pressing_event event
        else raise UnknownKeyValueError, "expect 0, 1 or 2 as event.value(#{event.value})"
        end

      if result  == :through
        fill_gap_pressed_state
        @operator.send_event event
      end

      handle_pressed_keys event

      LOG.info "pressed_keys real:#{@pressed_key_set.inspect} "+
        "virtual:#{@operator.pressed_key_set.inspect}" if LOG.info?
    end

    def handle_release_event event
      release_bind_set = []
      @active_bind_set.reject! do |key_bind|
        if key_bind.input.include? event.code
          release_bind_set << key_bind
          true
        else
          false
        end
      end

      if release_bind_set.empty?
        @key_resolver.default_value
      else
        release_bind_set.each do |kb|
          kb.output.each {|c|@operator.release_key c}
          if kb.input_recovery
            kb.input.clone.delete_if {|c|c==event.code}.each {|c|@operator.press_key c}
          end
        end
        :ignore
      end
    end

    # TODO fix bug: on Google Chrome, pressing C-fn invoke new window creation.
    # (C-fn mean pressing the n key with pressing C-f)
    def handle_press_event event
      r = @bind_resolver.resolve event, @pressed_key_set
      if r.kind_of? KeyBind
        r.input.clone.delete_if{|c|c==event.code}.each {|c| @operator.release_key c}
        r.output.each {|c| @operator.press_key c}
        @active_bind_set << r
        :ignore
      elsif r.kind_of? BindResolver
        @bind_resolver = r
        :ignore
      else
        r
      end
    end

    def handle_pressing_event event
      if @active_bind_set.empty?
        :through
      else
        @active_bind_set.each {|kb| kb.output.each {|c| @operator.pressing_key c}}
        :ignore
      end
    end

    def fill_gap_pressed_state
      return if @operator.pressed_key_set == @pressed_key_set
      sub = @pressed_key_set - @operator.pressed_key_set
      sub.each {|code| @operator.press_key code}
    end

    def handle_pressed_keys event
      if event.value == 1
        @pressed_key_set << event.code
        @pressed_key_set.sort! # TODO do not sort. implement an insertion like bubble
      elsif event.value == 0
        if @pressed_key_set.delete(event.code).nil?
          LOG.warn "#{event.code} does not exists on @pressed_keys" if LOG.warn?
        end
      end
    end

    class << self
      # parse and normalize to Fixnum/Array
      def parse_code code, depth = 0
        if code.kind_of? Symbol
          code = parse_symbol code
        elsif code.kind_of? Array
          raise ArgumentError, "expect Array is the depth less than 1" if depth >= 1
          code.map!{|c| parse_code c, (depth+1)}
        elsif code.kind_of? Fixnum and depth == 0
          code = [code]
        elsif not code.kind_of? Fixnum
          raise ArgumentError, "expect Symbol / Fixnum / Array"
        end
        code
      end

      # TODO convert :j -> KEY_J, :ctrl -> KEY_LEFTCTRL
      def parse_symbol sym
        if not sym.kind_of? Symbol
          raise ArgumentError, "expect Symbol / Fixnum / Array"
        end
        Revdev.const_get sym
      end

      def get_state_by_value ev
        case ev.value
        when 0; 'released '
        when 1; 'pressed  '
        when 2; 'pressing '
        end
      end
    end

  end

end
