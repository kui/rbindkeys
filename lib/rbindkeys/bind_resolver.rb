# -*- coding:utf-8; mode:ruby; -*-

module Rbindkeys

  class BindResolver
    DEFAULT_DEFAULT_VALUE = :through

    attr_reader :tree

    # returned value if no binds hit
    attr_reader :default_value

    def initialize default_value = DEFAULT_DEFAULT_VALUE
      @tree = {}
      @default_value = default_value
    end

    def bind input, output
      kb = KeyBind.new input, output
      @tree[input.last] ||= []
      @tree[input.last] << kb
      kb
    end

    def resolve key_code, key_code_set
    end

  end

end
