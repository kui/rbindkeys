# -*- coding:utf-8; mode:ruby; -*-

module Rbindkeys

  class BindResolver

    LOG = LogUtils.get_logger name
    DEFAULT_DEFAULT_VALUE = :through

    attr_reader :tree

    # returned value if no binds hit
    attr_reader :default_value

    def initialize default_value = DEFAULT_DEFAULT_VALUE
      @tree = {}
      @default_value = default_value
    end

    def bind input, output
      @tree[input.last] ||= []
      @tree[input.last].each do |b|
        if b.input == input
          raise DuplicateNodeError, "already this input(#{input.inspect}) was binded"
        end
      end

      kb = KeyBind.new input, output
      @tree[input.last] << kb # TODO implement a bubble insertion
      @tree[input.last].sort!{|a,b| b.input.length <=> a.input.length}
      kb
    end

    def resolve key_code, key_code_set
      arr = @tree[key_code]

      if arr.nil? or arr.empty?
        return @default_value
      end

      arr.each do |kb|
        sub = kb.input - key_code_set
        if sub.first == kb.input.last
          return kb
        end
      end

      @default_value
    end
  end
end
