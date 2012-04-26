# -*- coding:utf-8; mode:ruby; -*-

require 'rbindkeys'

include Rbindkeys

describe BindTree do
  describe '#resolve_for_released_event' do
    before do
      @bt = BindTree.new
      @kb = []
      @kb << KeyBind.new([1,2,3], [4,5,6])
      @kb << KeyBind.new([1,2,0], [6])
      @kb.each do |kb|
        @bt.bind kb.input, kb.output
      end
    end
    context "no pressed binds" do
      before do
        @ev = Revdev::InputEvent.new nil, Revdev::EV_KEY, 0, 0
      end
      it "'s pressed_binds should have empty" do
        @bt.active_leaves.should be_empty
        @bt.resolve_for_pressed_event @ev, []
        @bt.active_leaves.should be_empty
      end
    end
    context "a pressed bind" do
      before do
        ev = Revdev::InputEvent.new nil, Revdev::EV_KEY, 0, 1
        @bt.resolve_for_pressed_event ev, [1,2,4]
        @ev = Revdev::InputEvent.new nil, Revdev::EV_KEY, 0, 0
      end
      it "'s pressed_binds should empty" do
        exp = @bt.active_leaves
        @bt.active_leaves.size.should == 1
        @bt.resolve_for_released_event(@ev, [])[0].output.should == [6]
        @bt.active_leaves.should be_empty
      end
    end
    context "two pressed binds" do
      before do
        ev = Revdev::InputEvent.new nil, Revdev::EV_KEY, 0, 1
        @bt.resolve_for_pressed_event ev, [1,2,4]
        ev = Revdev::InputEvent.new nil, Revdev::EV_KEY, 3, 1
        @bt.resolve_for_pressed_event ev, [1,2,4]
        @ev = Revdev::InputEvent.new nil, Revdev::EV_KEY, 0, 0
      end
      it "'s pressed_binds should decrease" do
        @bt.active_leaves.length.should == 2
        @bt.resolve_for_released_event(@ev, [])
        @bt.active_leaves.length.should == 1
        @ev.code = 3
        @bt.resolve_for_released_event(@ev, [])
        @bt.active_leaves.should be_empty
      end
      it "'s pressed_binds should empty" do
        @ev.code = 1
        @bt.resolve_for_released_event(@ev, []).length.should == 2
        @bt.active_leaves.should be_empty
      end
    end
  end
end
