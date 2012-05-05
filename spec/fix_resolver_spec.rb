# -*- coding:utf-8; mode:ruby; -*-

require 'rbindkeys'

include Rbindkeys

describe FixResolver do

  describe ".instance" do
    context "with different value" do
      it "should return different instances" do
        f = FixResolver.instance :foo
        g = FixResolver.instance :bar
        f.equal?(g).should be_false
      end
      it "should return different instances" do
        f = FixResolver.instance :foo
        g = FixResolver.instance :foo
        f.equal?(g).should be_true
      end
    end
  end

  describe '.new' do
    context 'with any arg' do
      it 'should raise an exception' do
        lambda{FixResolver.new}.should raise_error
        lambda{FixResolver.new :foo}.should raise_error
      end
    end
  end

  describe '#bind' do
    before do
      @resolver = FixResolver.instance :foo
    end
    context 'with any args' do
      it 'should raise an exception' do
        lambda{@resolver.bind 1, 2}.should raise_error
        lambda{@resolver.bind [], []}.should raise_error
      end
    end
  end

  describe '#resolve' do
    before do
      @resolver = FixResolver.instance :foo
    end
    context 'with any args' do
      it 'should return :foo' do
        @resolver.resolve(1, []).should == :foo
        @resolver.resolve(3, [1,2]).should == :foo
      end
    end
  end

end
