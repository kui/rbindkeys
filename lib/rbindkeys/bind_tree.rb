# -*- coding:utf-8; mode:ruby; -*-

module Rbindkeys
  class BindTree

    # a tree structure which that nodes are Fixnum(keycode) and
    # leaves are Array of Fixnum(keycode)
    attr_reader :tree

    # active bind array
    attr_reader :pressing_binds

    def initialize
      @tree = {}
      @pressing_binds = []
    end

    # register an input-output pair
    # _input_: Array of input keycodes
    # _output_: Array of send keycodes or Proc
    def bind input, output
      input = input.clone
      tail_code = input.pop

      subtree = @tree
      last_code = -1
      input.each do |code|
        if subtree.has_key? code and (not subtree[code].kind_of? Hash)
          raise DuplicateNodeError, "already register an input:#{input}"
        elsif last_code >= code
          raise ArgumentError, "expect a sorted Array as input"
        end
        subtree[code] ||= {}
        subtree = subtree[code]
        last_code = code
      end

      if subtree.has_key? tail_code
        raise DuplicateNodeError, "already register an input:#{input}"
      end
      subtree[tail_code] = output
    end

    def resolve event, pressed_keys
    end

    # called when event.value == 0
    def resolve_for_release_event
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
      elsif subtree.kind_of? Array
        @pressing_binds << []
        return subtree
      else
        raise UnexpecedLeafError, "unexpeced Leaf: #{subtree.inspect}"
      end
    end

    # called when event.value == 2
    def resolve_for_pressing_event
    end

    class UnexpecedLeafError < RuntimeError; end
    class DuplicateNodeError < ArgumentError; end
  end
end
