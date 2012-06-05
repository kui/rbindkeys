# -*- coding:utf-8; mode:ruby; -*-
#
# a part of KeyEventHandler (see lib/rbindkeys/key_event_handler.rb)
#

module Rbindkeys
  class KeyEventHandler

    # pre-prosessed key codes replacement for all inputs
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

    # define a new key binding
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
        output = KeyEventHandler::parse_code output
      elsif output == :through or output == :ignore
      else
        raise ArgumentError, '2nd arg expect Array / Fixnum / BindResolver / '+
          'Symbol(:through/:ignore)'
      end

      LOG.info "bind_key #{input.inspect},\t#{output.inspect}\t#{resolver}" if LOG.info?

      resolver.bind input, output
    end

    # setting for 2stroke key binding
    # _input_ :: prefix key. (e.g. [KEY_LEFTCTRL, KEY_X] (C-x)
    # _resolver_ :: upper bind_resolver for fall throught
    # _block_ :: to define sub-binds on this prefix key bind
    def bind_prefix_key input, resolver=@bind_resolver, &block
      if not block_given?
        raise ArgumentError, "expect a block"
      end

      input = KeyEventHandler::parse_code input
      LOG.info "bind_prefix_key #{input.inspect}\t#{resolver}" if LOG.info?
      tmp = input.clone
      tail_input = tmp.pop

      binded_resolver = resolver.just_resolve tail_input, tmp
      if binded_resolver == nil
        binded_resolver = BindResolver.new :ignore, true
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

      old_resolver = @bind_resolver
      @bind_resolver = new_resolver
      yield
      @bind_resolver = old_resolver

      new_resolver
    end

    # switch bind_resolver if the active window match _arg_
    #
    # _upper\_resolver_ :: a upper bind_resolver, :through, :ignore
    # _arg_ :: a hash or a regexp
    #
    # ==arg
    # if a hash, which have entries :title => Regexp and/or :class => Regexp,
    # was given, this bind is active when the window title match with
    # :title's Regexp AND the window class match with :class's Regexp.
    # if a regexp was given, this bind is active when the window title match
    # with the given regexp
    def window upper_resolver, arg
      if upper_resolver.nil?
        upper_resolver = @bind_resolver
      elsif upper_resolver.kind_of? Symbol
        upper_resolver = FixResolver.instance upper_resolver
      elsif not upper_resolver.kind_of? BindResolver
        raise ArgumentError, "1nd argument is expected to be a BindResolver or"+
          " a Symbol : #{ upper_resolver.to_s}"
      end

      if arg.kind_of? Regexp
        arg = { :title => arg }
      elsif arg.kind_of? Hash
        arg.each do |k, v|
          if not (k.kind_of?(Symbol) and v.kind_of?(Regexp))
            raise ArgumentError, 'the 2nd argument Hash must only have'+
              " Symbol keys and Regexp values : #{arg.inspect}"
          end
        end
      else
        raise ArgumentError, "2nd argument is expected to be a Hash or a Regexp : #{arg}"
      end

      resolver = BindResolver.new(upper_resolver)
      @window_bind_resolver_map.push [WindowMatcher.new(arg), resolver]

      if block_given?
        old_resolver = @bind_resolver
        @bind_resolver = resolver
        yield
        @bind_resolver = old_resolver
      end

      resolver
    end

  end
end
