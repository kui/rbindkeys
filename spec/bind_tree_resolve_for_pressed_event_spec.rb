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
      @bt.bind [[4],[5]], [6]
    end

    describe "BindTree#resolve_for_pressed_event" do
      before do
        @ev = Revdev::InputEvent.new nil, Revdev::EV_KEY, 0, 1
      end
      context "with unsorted pressed keys" do
        it "should rase" do
          expect do
            @bt.resolve_for_pressed_event(@ev, [2, 1])
          end.to raise_error ArgumentError
        end
      end
      context "with binded pressed keys" do
        it "should return Arrays and pressing_binds added" do
          @ev.code = 0
          expect(@bt.resolve_for_pressed_event(@ev, [1,2]).output).to eq [6]
          expected_pressing_binds = [1, 2, @ev.code]
          expect(@bt.active_key_binds[0].input).to eq expected_pressing_binds

          @ev.code = 2
          expect(@bt.resolve_for_pressed_event(@ev, []).output).to eq [2]
          expected_pressing_binds = [@ev.code]
          expect(@bt.active_key_binds[1].input).to eq expected_pressing_binds
        end
      end
      context "with no binded pressed keys" do
        it "should return nil" do
          @ev.code = 5
          expect(@bt.resolve_for_pressed_event(@ev, [])).to eq @bt.default_value
          expect(@bt.resolve_for_pressed_event(@ev, [1])).to eq @bt.default_value
          @ev.code = 1
          expect(@bt.resolve_for_pressed_event(@ev, [])).to eq @bt.default_value
        end
      end
      context "with pressed keys as super set of binded keys" do
        it "should return Arrays" do
          @ev.code = 0
          expect(@bt.resolve_for_pressed_event(@ev, [1,2,4,5]).output).to eq [6]
          expect(@bt.resolve_for_pressed_event(@ev, [1,4,5,10]).output).to eq [55]
        end
      end
      context "with 2 stroke keybind" do
        it "should return Arrays" do
          @ev.code = 4
          tree = @bt.resolve_for_pressed_event(@ev, [])
          expect(tree).to be_a BindTree
          @ev.code = 5
          expect(tree.resolve_for_pressed_event(@ev, []).output).to eq [6]
        end
      end
    end
  end # context
end # describe
