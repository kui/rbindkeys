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
        expect(@resolver.tree[@input.last].first.input).to eq @input
        expect(@resolver.tree[@input.last].first.output).to eq @output
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
        expect(@resolver.tree[@input.last].first.input).to eq @input
        expect(@resolver.tree[@input.last].first.output).to eq @output
      end
    end
    context "with 2 BindResolver which is same as other one" do
      before do
        @input = [0, 1]
        @output = BindResolver.new :bar
      end
      it "should update @tree" do
        @resolver.bind @input, @output
        expect { @resolver.bind @input, [2,4] }.to raise_error(DuplicateNodeError)
      end
    end
    context "with Fixnum Arrays" do
      before do
      end
      it "should update @tree which store binds sort by modkey numbers" do
        @resolver.bind [0,2], [0,3]
        @resolver.bind [0,1,2], [1,3]
        @resolver.bind [3,2], [2,3]

        expect(@resolver.tree[2][0].output).to eq [1,3]
        expect(@resolver.tree[2][1].output).to eq [0,3]
        expect(@resolver.tree[2][2].output).to eq [2,3]
      end
    end
  end

  describe "#resolve" do
    before do
      @resolver2 = BindResolver.new(:ignore)
      @resolver.bind [0, 1], [2, 3]
      @resolver.bind [3, 1], [2, 4]
      @resolver.bind [0, 2], [2, 5]
      @resolver.bind [0, 1, 2], @resolver2
    end
    context "with an input which hit a bind" do
      before do
        @input = 1
        @pressed_key_set = [0]
      end
      it "should return the bind" do
        expect(@resolver.resolve(@input, @pressed_key_set)).to be_a KeyBind
        expect(@resolver.resolve(@input, @pressed_key_set).output).to eq [2, 3]
      end
    end
    context "with an input which hit a BindResolver" do
      before do
        @input = 2
        @pressed_key_set = [0,1]
      end
      it "should return the bind" do
        expect(@resolver.resolve(@input, @pressed_key_set)).to be_a KeyBind
        expect(@resolver.resolve(@input, @pressed_key_set).output).to eq @resolver2
      end
    end
    context "with an input which hit no binds" do
      before do
        @input = 2
        @pressed_key_set = [1]
      end
      it "should return default value" do
        expect(@resolver.resolve(@input, @pressed_key_set)).to eq :foo
      end
    end
  end
end
