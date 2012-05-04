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
        @resolver.bind [0,2], [2,3]
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
        @resolver.bind [0,2], [2,3]
        @resolver.tree[@input.last].first.input.should == @input
        @resolver.tree[@input.last].first.output.should == @output
      end
    end
    context "with 2 BindResolver which is same as other one" do
      before do
        @input = [0, 1]
        @output = BindResolver.new :bar
      end
      it "should update @tree" do
        @resolver.bind @input, @output
        lambda{@resolver.bind @input, [2,4]}.should raise_error(DuplicateNodeError)
      end
    end
  end

  describe "#resolve" do
    before do
      @resolver.bind [0, 1], [2, 3]
      @resolver.bind [3, 1], [2, 4]
      @resolver.bind [0, 2], [2, 5]
      @resolver.bind [0, 1, 2], BindResolver.new(:ignore)
    end
    context "with an input which hit a bind" do
      before do
        @input = 1
        @pressed_key_set = [0]
      end
      it "should return the bind" do
        @resolver.resolve(@input, @pressed_key_set).output.should == [2, 3]
      end
    end
  end
end
