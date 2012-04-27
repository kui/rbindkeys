# -*- coding:utf-8; mode:ruby; -*-

require 'rbindkeys'

include Rbindkeys

describe BindTree do
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
            @bt.resolve_for_pressed_event(@ev, [2, 1])
            violated "should raise"
          rescue => e
          end
        end
      end
      context "with binded pressed keys" do
        it "should return Arrays and pressing_binds added" do
          @ev.code = 0
          @bt.resolve_for_pressed_event(@ev, [1,2]).output.should == [6]
          expected_pressing_binds = [1, 2, @ev.code]
          @bt.active_key_binds[0].input.should == expected_pressing_binds

          @ev.code = 2
          @bt.resolve_for_pressed_event(@ev, []).output.should == [2]
          expected_pressing_binds = [@ev.code]
          @bt.active_key_binds[1].input.should == expected_pressing_binds
        end
      end
      context "with no binded pressed keys" do
        it "should return nil" do
          @ev.code = 4
          @bt.resolve_for_pressed_event(@ev, []).should be_nil
          @bt.resolve_for_pressed_event(@ev, [1]).should be_nil
          @ev.code = 1
          @bt.resolve_for_pressed_event(@ev, []).should be_nil
        end
      end
      context "with pressed keys as super set of binded keys" do
        it "should return Arrays" do
          @ev.code = 0
          @bt.resolve_for_pressed_event(@ev, [1,2,4,5]).output.should == [6]
          @bt.resolve_for_pressed_event(@ev, [1,4,5,10]).output.should == [55]
        end
      end
    end
  end # context
end # describe
