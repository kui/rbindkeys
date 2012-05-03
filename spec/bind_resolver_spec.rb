# -*- coding:utf-8; mode:ruby; -*-

require 'rbindkeys'
require 'revdev'

include Rbindkeys

describe BindResolver do
  before do
    @resolver = BindResolver.new :foo
  end

  describe "#bind" do
    context "with two Fixnum Array" do
      before do
        @input = [0, 1]
        @output = [2, 3]
      end
      it "should update @tree" do
        @resolver.bind @input, @output
        @resolver.tree[@input.last].first.input.should == @input
        @resolver.tree[@input.last].first.output.should == @output
      end
    end
    context "with a Fixnum Array and a BindResolver" do
      before do
        @input = [0, 1]
        @output = BindResolver.new :bar
      end
      it "should update @tree" do
        @resolver.bind @input, @output
        @resolver.tree[@input.last].first.input.should == @input
        @resolver.tree[@input.last].first.output.should == @output
      end
    end
  end

  describe "#resolve" do
  end
end
