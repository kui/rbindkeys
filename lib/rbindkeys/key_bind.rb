# -*- coding:utf-8; mode:ruby; -*-

module Rbindkeys
  class KeyBind

    attr_reader :input
    attr_reader :output

    def initialize input, output
      raise ArgumentError, "input expected as Array" if not input.kind_of? Array
      raise ArgumentError, "output expected as Array" if not output.kind_of? Array

      @input = input
      @output = output
    end
  end
end
