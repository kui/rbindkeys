# -*- coding:utf-8; mode:ruby; -*-
#
# a part of KeyEventHandler (see lib/rbindkeys/key_event_handler.rb)
#

module Rbindkeys
  class KeyEventHandler

    def pre_bind_key input, output
      if not (input.kind_of? Fixnum and output.kind_of? Fixnum)
        raise ArgumentError, 'expect Fixnum for input and output'
      end

      if @pre_bind_resolver.has_key? input
        raise DuplicateNodeError, "1st arg (#{input}) was already entried"
      end

      LOG.info "pre_bind_key #{input.inspect},\t#{output.inspect}" if LOG.info?

      @pre_bind_resolver[input] = output
      [input, output]
    end

    def bind_key input, output=nil, resolver=@bind_resolver, &block
      if input.kind_of?(Array) or input.kind_of?(Fixnum)
        input = KeyEventHandler.parse_code input
      else
        raise ArgumentError, '1st arg expect Array / Fixnum'
      end
      if block_given?
        output = block
      elsif output.nil?
        raise ArgumentError, 'expect 1 arg with a block / 2 args'
      elsif output.kind_of? BindResolver
      elsif output.kind_of?(Array) or output.kind_of?(Fixnum)
        output = KeyEventHandler.parse_code output
      else
        raise ArgumentError, '2nd arg expect Array / Fixnum / BindResolver'
      end

      LOG.info "bind_key #{input.inspect},\t#{output.inspect}\t#{resolver}" if LOG.info?

      resolver.bind input, output
    end

    def bind_prefix_key input, resolver=@bind_resolver, &block
      if not block_given?
        raise ArgumentError, "expect a block"
      end

      input = KeyEventHandler.parse_code input
      LOG.info "bind_prefix_key #{input.inspect}\t#{resolver}" if LOG.info?
      tmp = input.clone
      tail_input = tmp.pop

      binded_resolver = resolver.just_resolve tail_input, tmp
      if binded_resolver == nil
        binded_resolver = BindResolver.new :ignore
        resolver.bind input, binded_resolver
      elsif not binded_resolver.kind_of? BindResolver
        raise DuplicateNodeError, "the codes (#{input.inspect}) was already binded"
      end

      @bind_resolver = binded_resolver
      yield
      @bind_resolver = resolver
      binded_resolver
    end

    def new_bind_resolver upper_resolver=@bind_resolver, &block
      if not block_given?
        raise ArgumentError, "expect a block"
      end

      new_resolver = BindResolver.new upper_resolver
      @bind_resolver = new_resolver
      yield
      @bind_resolver = upper_resolver

      new_resolver
    end

    def window arg
    end

  end
end
