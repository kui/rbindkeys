# -*- coding:utf-8; mode:ruby; -*-

module Rbindkeys
  class BindResolver
    LOG = LogUtils.get_logger name
    DEFAULT_VALUE = :through

    attr_reader :tree

    # delegate if cannot resolved
    attr_reader :upper_resolver

    # if this resolver is set by prefix key, then true
    # else, false
    attr_reader :two_stroke
    alias two_stroke? two_stroke

    def initialize(upper_resolver=:through, two_stroke=false)
      @tree = {}
      if upper_resolver.is_a? Symbol
        upper_resolver = FixResolver.instance upper_resolver
      end
      @upper_resolver = upper_resolver
      @two_stroke = two_stroke
    end

    def bind(input, output)
      @tree[input.last] ||= []
      @tree[input.last].each do |b|
        if b.input == input
          fail DuplicateNodeError, "already this input(#{input.inspect}) was binded"
        end
      end

      kb = KeyBind.new input, output
      @tree[input.last] << kb # TODO: implement a bubble insertion
      @tree[input.last].sort! {|a, b| b.input.length <=> a.input.length }
      kb
    end

    def resolve(key_code, key_code_set)
      just_resolve(key_code, key_code_set) or
        @upper_resolver.resolve(key_code, key_code_set)
    end

    def just_resolve(key_code, key_code_set)
      arr = @tree[key_code]
      arr.each do |kb|
        sub = kb.input - key_code_set
        sub.first == kb.input.last and
          return kb
      end unless arr.nil?
      nil
    end
  end
end
