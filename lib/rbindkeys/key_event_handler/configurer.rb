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

    def bind_key input, output, resolver=@bind_resolver
      input = KeyEventHandler.parse_code input
      output = KeyEventHandler.parse_code output

      LOG.info "bind_key #{input.inspect},\t#{output.inspect}\t#{resolver}" if LOG.info?

      resolver.bind input, output
    end

    def bind_prefix_key input, resolver=@bind_resolver
      if not block_given?
        raise ArgumentError, "expect to a block"
      end

      input = KeyEventHandler.parse_code input
      LOG.info "bind_prefix_key #{input.inspect}\t#{resolver}" if LOG.info?
      tmp = input.clone
      tail_input = tmp.pop

      binded_resolver = resolver.resolve tail_input, tmp
      if binded_resolver == resolver.default_value
        binded_resolver = BindResolver.new
        resolver.bind input, binded_resolver
      end

      @bind_resolver = binded_resolver
      yield
      @bind_resolver = resolver
      binded_resolver
    end

  end
end
