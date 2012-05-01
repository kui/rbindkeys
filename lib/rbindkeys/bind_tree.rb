# -*- coding:utf-8; mode:ruby; -*-

module Rbindkeys
  class BindTree

    DEFAULT_DEFAULT_VALUE = :through
    AVAIVABLE_DEFAULT_VALUE = [:through, :ignore]

    # a tree structure which that nodes are Fixnum(keycode) and
    # leaves are Leaf
    attr_reader :tree

    attr_reader :main_tree

    # active KeyBind
    # TODO create KeyEventHandler which exist between Observer and BindTree
    # TODO move out @active_key_binds to KeyEventHandler
    attr_reader :active_key_binds

    # a value if no binds hit
    attr_reader :default_value

    def initialize default_value=DEFAULT_DEFAULT_VALUE
      @tree = {}
      @active_key_binds = []
      if AVAIVABLE_DEFAULT_VALUE.include? default_value
        @default_value = default_value
      else
        raise ArgumentError, "expect #{AVAIVABLE_DEFAULT_VALUE.join('/')}"
      end
    end

    # register an input-output pair
    # _input_: Array of (Array of) input keycodes
    # _output_: Array of send keycodes or Proc
    def bind input, output=nil
      input = input.clone
      new_input = []

      if input.kind_of? Array and input[0].kind_of? Array
        new_input = input
        input = new_input.shift
      end

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

      if not new_input.empty?
        if subtree.has_key?(tail_code) and
            not (subtree[tail_code].kind_of?(Leaf) and
                 subtree[tail_code].payload.kind_of?(BindTree))
          raise DuplicateNodeError, "already register an input:#{input}"
        end

        if new_input.length == 1
          new_input = new_input.first
        end

        subtree[tail_code] ||= Leaf.new BindTree.new :ignore
        subtree[tail_code].payload.bind new_input, output

      elsif subtree.has_key? tail_code
        raise DuplicateNodeError, "already register an input:#{input}"

      else
        subtree[tail_code] = Leaf.new KeyBind.new input.push(tail_code), output
      end
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

      if release_binds.empty?
        :through
      else
        release_binds
      end
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
        return @default_value
      elsif subtree.kind_of? Leaf
        if subtree.payload.kind_of? KeyBind
          @active_key_binds << subtree.payload
          return subtree.payload
        elsif subtree.payload.kind_of? BindTree
          return subtree.payload
        end
      else
        raise UnexpecedLeafError, "unexpeced Leaf: #{subtree.inspect}"
      end
    end

    # called when event.value == 2
    def resolve_for_pressing_event event, pressed_keys
      if @active_key_binds.empty?
        @default_value
      else
        @active_key_binds
      end
    end

    class Leaf
      attr_reader :payload

      def initialize payload
        @payload = payload
      end
    end

    class UnexpecedLeafError < RuntimeError; end
  end
end
