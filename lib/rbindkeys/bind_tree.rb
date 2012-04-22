# -*- coding:utf-8; mode:ruby; -*-

module Rbindkeys
  class BindTree

    # a tree structure which that nodes are Fixnum(keycode) and
    # leaves are Array of Fixnum(keycode)
    attr_reader :tree

    def initialize
      @tree = {}
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

    def resolve input
      input = input.clone
      tail_code = input.pop

      subtree = @tree
      last_code = -1
      input.each do |code|
        if last_code >= code
          raise ArgumentError, "expect a sorted Array as input"
        end
        last_code = code
        subtree = subtree[code]
        break if subtree.nil?
      end

      if subtree.nil?
        return nil
      else
        return subtree[tail_code]
      end
    end

    class DuplicateNodeError < ArgumentError; end
  end
end
