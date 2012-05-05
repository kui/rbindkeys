# -*- coding:utf-8; mode:ruby; -*-

module Rbindkeys

  # last resolvers which return @val as the resolve result
  class FixResolver < BindResolver
    private_class_method :new
    @@pool = {}

    def self.instance val
      @@pool[val] or (@@pool[val] = new val)
    end

    def initialize val
      @val = val
    end

    def bind input, output
      raise RuntimeError, 'cannot bind any input/output'
    end

    def resolve code, code_set
      @val
    end
  end
end
