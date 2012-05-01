# -*- coding:utf-8; mode:ruby; -*-

module Rbindkeys

  # retrive key binds with key event
  class KeyEventHandler
    include Revdev

    LOG = LogUtils.get_logger name

    # event device to read events
    attr_reader :device

    # virtual device to write events
    attr_reader :virtual

    # defaulut key bind set which retrive key binds with a key event
    attr_reader :default_bind_resolver

    # current key bind set which retrive key binds with a key event
    attr_reader :bind_resolver

    #  proccessed resolver before bind_resolver
    attr_reader :pre_bind_resolver

    # code set of pressed key on the event device
    attr_reader :pressed_key_set

    # code set of pressed keys on the virtual device
    attr_reader :virtual_pressed_key_set

    # pressed key binds
    attr_reader :active_bind_set

    def initialize dev, virtual_dev
      @device = dev
      @virtual = virtual_dev
      @default_bind_resolver = BindResolver.new
      @bind_resolver = @default_bind_resolver
      @pre_bind_resolver = {}
      @pressed_key_set = []
      @virtual_pressed_key_set = []
      @active_bind_set = []
    end

    def load_config file
      code = File.read file
      instance_eval code, file
    end

    def pre_bind_key input, output
      if not (input.kind_of? Fixnum and output.kind_of? Fixnum)
        raise ArgumentError, 'expect Fixnum for input and output'
      end

      if @pre_bind_resolver.has_key? input
        raise DuplicateNodeError, "1st arg (#{input}) was already entried"
      end

      LOG.info "pre_bind_key #{input.inspect},\t#{output.inspect}"

      @pre_bind_resolver[input] = output
      [input, output]
    end

    def bind_key input, output, resolver=@bind_resolver
      input = parse_code input
      output = parse_code output

      LOG.info "bind_key #{input.inspect},\t#{output.inspect}\t#{resolver}"

      resolver.bind input, output
    end

    def bind_prefix_key input, resolver=@bind_resolver
      if not block_given?
        raise ArgumentError, "expect to a block"
      end

      input = parse_code input.clone
      tail_input = input.pop

      binded_resolver = @bind_resolver.resolve tail_input, input
      if binded_resolver == @bind_resolver.default_value
        binded_resolver = BindResolver.new
        resolver.bind input, binded_resolver
      end

      @bind_resolver = binded_resolver
      yield
      @binded_resolver = resolver
      binded_resolver
    end

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

  end

end
