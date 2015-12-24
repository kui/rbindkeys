# -*- coding:utf-8; mode:ruby; -*-

require 'rbindkeys'

include Rbindkeys

describe FixResolver do

  describe ".instance" do
    context "with different value" do
      it "should return different instances" do
        f = FixResolver.instance :foo
        g = FixResolver.instance :bar
        expect(f).to_not eq g
      end
      it "should return different instances" do
        f = FixResolver.instance :foo
        g = FixResolver.instance :foo
        expect(f).to eq g
      end
    end
  end

  describe '#bind' do
    before do
      @resolver = FixResolver.instance :foo
    end
    context 'with any args' do
      it 'should raise an exception' do
        expect { @resolver.bind 1,  2  }.to raise_error RuntimeError
        expect { @resolver.bind [], [] }.to raise_error RuntimeError
      end
    end
  end

  describe '#resolve' do
    before do
      @resolver = FixResolver.instance :foo
    end
    context 'with any args' do
      it 'should return :foo' do
        expect(@resolver.resolve(1, []   )).to eq :foo
        expect(@resolver.resolve(3, [1,2])).to eq :foo
      end
    end
  end
end
