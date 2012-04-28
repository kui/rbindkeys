# -*- coding:utf-8; mode:ruby; -*-

module Rbindkeys
  class KeyBind

    attr_reader :input

    attr_reader :output

    # when a signal of any input release event was accepted,
    # if @inputs_recovery is true, outputs are released and other inputs are pressed,
    # if @inputs_recovery is false or nil, outputs are released.
    attr_reader :input_recovery

    def initialize input, output, opt = {}
      raise ArgumentError, "input expected as Array" if not input.kind_of? Array
      raise ArgumentError, "output expected as Array" if not output.kind_of? Array

      @input = input
      @output = output
      @input_recovery = opt[:input_recovery]
    end
  end
end
