# -*- coding:utf-8; mode:ruby; -*-

module Rbindkeys
  class BindTree

    # a tree structure which that nodes are Fixnum(keycode) and
    # leaves are Leaf
    attr_reader :tree

    # active KeyBind
    attr_reader :active_key_binds

    def initialize
      @tree = {}
      @active_key_binds = []
    end

    # register an input-output pair
    # _input_: Array of input keycodes
    # _output_: Array of send keycodes or Proc
    def bind input, output=nil
      input = input.clone
      tail_code = input.pop
      input.sort!

      subtree = @tree
      input.each do |code|
        if subtree.has_key? code and (not subtree[code].kind_of? Hash)
          raise DuplicateNodeError, "already register an input:#{input}"
        end
        subtree[code] ||= {}
        subtree = subtree[code]
      end

      if subtree.has_key? tail_code
        raise DuplicateNodeError, "already register an input:#{input}"
      end
      subtree[tail_code] = Leaf.new KeyBind.new input.push(tail_code), output
    end

    # called when event.value == 0
    def resolve_for_released_event event, pressed_keys
      release_binds = []
      @active_key_binds.reject! do |key_bind|
        if key_bind.input.include? event.code
          release_binds << key_bind
          true
        else
          false
        end
      end
      return release_binds
    end

    # called when event.value == 1
    def resolve_for_pressed_event event, pressed_keys
      subtree = @tree
      last_code = -1
      pressed_keys.each do |code|
        if last_code >= code
          raise ArgumentError, "expect a sorted Array for 2nd arg (pressed_keys)"
        end
        last_code = code

        if subtree.has_key? code
          subtree = subtree[code]
        end
      end

      subtree = (subtree.kind_of?(Hash) and subtree[event.code])

      if not subtree or subtree.kind_of? Hash
        return nil
      elsif subtree.kind_of? Leaf and subtree.payload.kind_of? KeyBind
        @active_key_binds << subtree.payload
        return subtree.payload
      else
        raise UnexpecedLeafError, "unexpeced Leaf: #{subtree.inspect}"
      end
    end

    # called when event.value == 2
    def resolve_for_pressing_event event, pressed_keys
      @active_key_binds
    end

    class Leaf
      attr_reader :payload

      def initialize payload
        @payload = payload
      end
    end

    class UnexpecedLeafError < RuntimeError; end
    class DuplicateNodeError < ArgumentError; end
  end
end
