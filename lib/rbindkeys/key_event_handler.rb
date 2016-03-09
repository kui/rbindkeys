# -*- coding:utf-8; mode:ruby; -*-

require 'rbindkeys/key_event_handler/configurer'

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

    # a hash (key:WindowMatcher, val:BindResolver) to switch BindResolver
    # by the title or app_name of active window
    attr_reader :window_bind_resolver_map

    # proccessed resolver before bind_resolver
    attr_reader :pre_bind_resolver

    # code set of pressed key on the event device
    attr_reader :pressed_key_set

    # pressed key binds
    attr_reader :active_bind_set

    def initialize(device_operator)
      @operator = device_operator
      @default_bind_resolver = BindResolver.new
      @window_bind_resolver = nil
      @bind_resolver = @default_bind_resolver
      @window_bind_resolver_map = []
      @pre_bind_resolver = {}
      @pressed_key_set = []
      @active_bind_set = []
    end

    def load_config(file)
      code = File.read file
      instance_eval code, file
    end

    def handle(event)
      if LOG.info?
        LOG.info '' unless LOG.debug?
        LOG.info "read\t#{KeyEventHandler.get_state_by_value event} " +
          "#{event.hr_code}(#{event.code})"
      end

      # handle pre_key_bind_set
      event.code = (@pre_bind_resolver[event.code] or event.code)

      # swich to handle event with event.value
      result =
        case event.value
        when 0 then handle_release_event event
        when 1 then handle_press_event event
        when 2 then handle_pressing_event event
        else fail UnknownKeyValue, "expect 0, 1 or 2 as event.value(#{event.value})"
        end

      case result
      when :through
        fill_gap_pressed_state event if event.value == 1
        @operator.send_event event
      when :ignore
        # ignore the original event
      end

      handle_pressed_keys event

      LOG.info "pressed_keys real:#{@pressed_key_set.inspect} " +
        "virtual:#{@operator.pressed_key_set.inspect}" if LOG.info?
    end

    def handle_release_event(event)
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
        :through
      else
        release_bind_set.each do |kb|
          kb.output.each {|c| @operator.release_key c }
          if kb.input_recovery
            kb.input.reject {|c| c == event.code }.each {|c| @operator.press_key c }
          end
        end
        :ignore
      end
    end

    def set_bind_resolver(resolver)
      old_resolver = @bind_resolver if LOG.info?
      @bind_resolver = resolver
      LOG.info "switch bind_resolver: #{old_resolver} => " +
        @bind_resolver.to_s if LOG.info?
      @bind_resolver
    end

    def handle_press_event(event)
      r = @bind_resolver.resolve event.code, @pressed_key_set

      LOG.debug "resolve result: #{r.inspect}" if LOG.debug?

      if r.is_a? KeyBind

        if @bind_resolver.two_stroke?
          set_bind_resolver (@window_bind_resolver or @default_bind_resolver)
        end

        if r.output.is_a? Array
          r.input.reject {|c| c == event.code }.each {|c| @operator.release_key c }
          r.output.each {|c| @operator.press_key c }
          @active_bind_set << r
          :ignore
        elsif r.output.is_a? BindResolver
          set_bind_resolver r.output
          :ignore
        elsif r.output.is_a? Proc
          r.output.call event, @operator
        elsif r.output.is_a? Symbol
          r
        end
      else
        r
      end
    end

    def handle_pressing_event(_event)
      if @active_bind_set.empty?
        :through
      else
        @active_bind_set.each {|kb| kb.output.each {|c| @operator.pressing_key c } }
        :ignore
      end
    end

    def fill_gap_pressed_state(event)
      return if @operator.pressed_key_set == @pressed_key_set
      sub = @pressed_key_set - @operator.pressed_key_set
      sub.delete event.code if event.value == 0
      sub.each {|code| @operator.press_key code }
    end

    def handle_pressed_keys(event)
      if event.value == 1
        @pressed_key_set << event.code
        @pressed_key_set.sort! # TODO: do not sort. implement an bubble insertion
      elsif event.value == 0
        if @pressed_key_set.delete(event.code).nil?
          LOG.warn "#{event.code} does not exists on @pressed_keys" if LOG.warn?
        end
      end
    end

    def active_window_changed(window)
      if not window.nil?
        title = window.title
        app_name = window.app_name
        if LOG.info?
          LOG.info '' unless LOG.debug?
          LOG.info "change active_window: :class => \"#{app_name}\", :title => \"#{title}\""
        end

        @window_bind_resolver_map.each do |matcher, bind_resolver|
          next unless matcher.match? app_name, title
          if LOG.info?
            LOG.info "=> matcher #{matcher.app_name.inspect}, #{matcher.title.inspect}"
            LOG.info "   bind_resolver #{bind_resolver.inspect}"
          end
          set_bind_resolver bind_resolver
          @window_bind_resolver = bind_resolver
          return
        end
      else
        if LOG.info?
          LOG.info '' unless LOG.debug?
          LOG.info 'change active_window: nil'
        end
      end

      LOG.info '=> no matcher' if LOG.info?
      set_bind_resolver @default_bind_resolver
      @window_bind_resolver = nil
      nil
    end

    class << self
      # parse and normalize to Fixnum/Array
      def parse_code(code, depth=0)
        if code.is_a? Symbol
          code = parse_symbol code
        elsif code.is_a? Array
          fail ArgumentError, 'expect Array is the depth less than 1' if depth >= 1
          code.map! {|c| parse_code c, (depth + 1) }
        elsif code.is_a? Fixnum and depth == 0
          code = [code]
        elsif not code.is_a? Fixnum
          fail ArgumentError, 'expect Symbol / Fixnum / Array'
        end
        code
      end

      # TODO: convert :j -> KEY_J, :ctrl -> KEY_LEFTCTRL
      def parse_symbol(sym)
        unless sym.is_a? Symbol
          fail ArgumentError, 'expect Symbol / Fixnum / Array'
        end
        Revdev.const_get sym
      end

      def get_state_by_value(ev)
        case ev.value
        when 0 then 'released '
        when 1 then 'pressed  '
        when 2 then 'pressing '
        end
      end
    end
  end
end
