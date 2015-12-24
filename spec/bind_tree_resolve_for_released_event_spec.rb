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
        expect(@bt.active_key_binds).to be_empty
        expect(@bt.resolve_for_pressed_event(@ev, [])).to eq @bt.default_value
        expect(@bt.active_key_binds).to be_empty
      end
    end
    context "a pressed bind" do
      before do
        ev = Revdev::InputEvent.new nil, Revdev::EV_KEY, 0, 1
        @bt.resolve_for_pressed_event ev, [1,2,4]
        @ev = Revdev::InputEvent.new nil, Revdev::EV_KEY, 0, 0
      end
      it "'s pressed_binds should empty" do
        expect(@bt.active_key_binds.size).to eq 1
        expect(@bt.resolve_for_released_event(@ev, [])[0].output).to eq [6]
        expect(@bt.active_key_binds).to be_empty
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
        expect(@bt.active_key_binds.length).to eq 2
        @bt.resolve_for_released_event(@ev, [])
        expect(@bt.active_key_binds.length).to eq 1
        @ev.code = 3
        @bt.resolve_for_released_event(@ev, [])
        expect(@bt.active_key_binds).to be_empty
      end
      it "'s pressed_binds should empty" do
        @ev.code = 1
        expect(@bt.resolve_for_released_event(@ev, []).length).to eq 2
        expect(@bt.active_key_binds).to be_empty
      end
    end
  end
end
