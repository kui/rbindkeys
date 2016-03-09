# -*- coding:utf-8; mode:ruby; -*-

module Rbindkeys
  class BindTree
    DEFAULT_DEFAULT_VALUE = :through
    AVAIVABLE_DEFAULT_VALUE = [:through, :ignore].freeze

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

    def initialize(default_value=DEFAULT_DEFAULT_VALUE)
      @tree = {}
      @active_key_binds = []
      if AVAIVABLE_DEFAULT_VALUE.include? default_value
        @default_value = default_value
      else
        fail ArgumentError, "expect #{AVAIVABLE_DEFAULT_VALUE.join('/')}"
      end
    end

    # register an input-output pair
    # _input_: Array of (Array of) input keycodes
    # _output_: Array of send keycodes or Proc
    def bind(input, output=nil)
      input = input.clone
      new_input = []

      if input.is_a? Array and input[0].is_a? Array
        new_input = input
        input = new_input.shift
      end

      tail_code = input.pop
      input.sort!

      subtree = @tree
      input.each do |code|
        if subtree.key? code and (not subtree[code].is_a? Hash)
          fail DuplicateNodeError, "already register an input:#{input}"
        end
        subtree[code] ||= {}
        subtree = subtree[code]
      end

      if not new_input.empty?
        if subtree.key?(tail_code) and
            not (subtree[tail_code].is_a? Leaf and
                 subtree[tail_code].payload.is_a? BindTree)
          fail DuplicateNodeError, "already register an input:#{input}"
        end

        new_input = new_input.first if new_input.length == 1

        subtree[tail_code] ||= Leaf.new BindTree.new :ignore
        subtree[tail_code].payload.bind new_input, output

      elsif subtree.key? tail_code
        fail DuplicateNodeError, "already register an input:#{input}"

      else
        subtree[tail_code] = Leaf.new KeyBind.new input.push(tail_code), output
      end
    end

    # called when event.value == 0
    def resolve_for_released_event(event, _pressed_keys)
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
    def resolve_for_pressed_event(event, pressed_keys)
      subtree = @tree
      last_code = -1
      pressed_keys.each do |code|
        if last_code >= code
          fail ArgumentError, 'expect a sorted Array for 2nd arg (pressed_keys)'
        end
        last_code = code

        subtree = subtree[code] if subtree.key? code
      end

      subtree = (subtree.is_a? Hash and subtree[event.code])

      if not subtree or subtree.is_a? Hash
        return @default_value
      elsif subtree.is_a? Leaf
        if subtree.payload.is_a? KeyBind
          @active_key_binds << subtree.payload
          return subtree.payload
        elsif subtree.payload.is_a? BindTree
          return subtree.payload
        end
      else
        fail UnexpecedLeafError, "unexpeced Leaf: #{subtree.inspect}"
      end
    end

    # called when event.value == 2
    def resolve_for_pressing_event(_event, _pressed_keys)
      if @active_key_binds.empty?
        @default_value
      else
        @active_key_binds
      end
    end

    class Leaf
      attr_reader :payload

      def initialize(payload)
        @payload = payload
      end
    end

    class UnexpecedLeafError < RuntimeError; end
  end
end
