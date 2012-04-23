# -*- coding:utf-8; mode:ruby; -*-

require 'rbindkeys'

include Rbindkeys

describe BindTree do
  context "normal" do
    describe 'BindTree#bind' do
      before do
        @bt = BindTree.new
      end

      context 'with valid input/output' do
        it "should construct expected tree" do
          input = [1,2]
          @bt.bind input, [2,3]
          input.should == [1,2] # should not destroyable
          @bt.bind [1,0], [2,3]
          @bt.bind [2], [2,4]
          @bt.tree.should == {1=>{2=>[2,3],0=>[2,3]}, 2=>[2,4]}
        end
      end
      context 'with duplicate node input' do
        it "should raise DuplicateNodeError" do
          @bt.bind [1,2], [2,3]
          begin
            @bt.bind [1,2], [2,4]
            violated "should raise"
          rescue => e
            e.class.should == BindTree::DuplicateNodeError
          end
        end
        it "should raise DuplicateNodeError" do
          @bt.bind [1,2], [2,3]
          begin
            @bt.bind [1,2,6], [2,4]
            violated "should raise"
          rescue => e
            e.class.should == BindTree::DuplicateNodeError
          end
        end
      end
      context "with unsorted input" do
        it "should raise ArgumentError" do
          begin
            @bt.bind [3,2,6], [2,4]
            violated "should raise"
          rescue => e
            e.class.should == ArgumentError
          end
        end
      end
    end # describe
  end

  context "BindTree constracted" do
    before do
      @bt = BindTree.new
      @bt.bind [1,2,3], [4,5,6]
      @bt.bind [1,2,0], [6]
      @bt.bind [1,3], [5,6]
      @bt.bind [1,10,0], [55]
      @bt.bind [2], [2]
    end

    describe "BindTree#resolve_for_pressed_event" do
      before do
        @ev = Revdev::InputEvent.new nil, Revdev::EV_KEY, 0, 1
      end
      context "with unsorted pressed keys" do
        it "should rase" do
          begin
            @bt.resolve(@ev, [2, 1]).should
            violated "should raise"
          rescue => e
          end
        end
      end
      context "with binded pressed keys" do
        it "should return Arrays" do
          @bt.resolve(@ev, [1,2]).should == [6]
          @ev.code = 2
          @bt.resolve(@ev, []).should == [2]
        end
      end
      context "with no binded pressed keys" do
        it "should return nil" do
          @ev.code = 4
          @bt.resolve(@ev, []).should be_nil
          @bt.resolve(@ev, [1]).should be_nil
          @ev.code = 1
          @bt.resolve(@ev, []).should be_nil
        end
      end
      context "with pressed keys as super set of binded keys" do
        it "should return Arrays" do
          @bt.resolve(@ev, [1,2,4,5]).should == [6]
          @bt.resolve(@ev, [1,4,5,10]).should == [55]
        end
      end
    end
  end # context
end # describe
