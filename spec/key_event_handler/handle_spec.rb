# -*- coding:utf-8; mode:ruby; -*-

require 'rbindkeys'
require 'revdev'

include Rbindkeys

describe KeyEventHandler do
  before do
    @ope = double DeviceOperator
    allow(@ope).to receive(:pressed_key_set) { [] }
    @resolver = double BindResolver
    @resolver2 = BindResolver.new
    allow(BindResolver).to receive(:new) { @resolver }
    allow(@resolver).to receive(:two_stroke?) { false }

    @handler = KeyEventHandler.new @ope
  end

  describe "#handle" do
    context "with a pressed event" do
      before do
        @event = Revdev::InputEvent.new nil, Revdev::EV_KEY, Revdev::KEY_K, 1
      end
      context "if handle_pressed_event return :through" do
        before do
          expect(@handler).to receive(:handle_press_event) { :through }
        end
        it "shoud send @event" do
          expect(@ope).to receive(:send_event).with(@event)
          @handler.handle @event
        end
      end

      context "if handle_pressed_event return :ignore" do
        before do
          expect(@handler).to receive(:handle_press_event) { :ignore }
        end
        it "shoud ignore @event" do
          expect(@ope).to_not receive(:send_event)
          @handler.handle @event
        end
      end
    end

    context "with a released event" do
      before do
        @event = Revdev::InputEvent.new nil, Revdev::EV_KEY, Revdev::KEY_K, 0
        expect(@handler).to receive(:handle_release_event) { :ignore }
      end
      it "shoud ignore @event" do
        expect(@ope).to_not receive(:send_event)
        @handler.handle @event
      end
    end

    context "with a pressing event" do
      before do
        @event = Revdev::InputEvent.new nil, Revdev::EV_KEY, Revdev::KEY_K, 2
        expect(@handler).to receive(:handle_pressing_event) { :ignore }
      end
      it "shoud ignore @event" do
        expect(@ope).to_not receive(:send_event)
        @handler.handle @event
      end
    end
  end

  describe "#handle_press_event" do
    before do
      @event = Revdev::InputEvent.new nil, Revdev::EV_KEY, 1, 1
    end
    context "with an event which hit a key bind" do
      before do
        @key_bind = KeyBind.new [0,1], [2,3]
        expect(@resolver).to receive(:resolve).and_return(@key_bind)
      end
      it "should return :ignore, send messages to @ope and update @active_bind_set" do
        expect(@ope).to receive(:press_key).with(2)
        expect(@ope).to receive(:press_key).with(3)
        expect(@ope).to receive(:release_key).with(0)
        expect(@handler.handle_press_event(@event)).to be :ignore
        expect(@handler.active_bind_set).to eq [@key_bind]
      end
    end
    context "with an event which hit a BindResolver" do
      before do
        @key_bind = KeyBind.new [0,1], @resolver2
        expect(@resolver).to receive(:resolve).and_return(@key_bind)
      end
      it "should return :ignore and update @bind_resolver" do
        expect(@handler.handle_press_event(@event)).to be :ignore
        expect(@handler.bind_resolver).to be @resolver2
      end
    end
    context "with an event which hit a Proc" do
      before do
        @proc = proc { :foo }
        @key_bind = KeyBind.new [0,1], @proc
        expect(@resolver).to receive(:resolve).and_return(@key_bind)
      end
      it "should return :ignore and update @bind_resolver" do
        expect(@handler.handle_press_event(@event)).to be :foo
      end
    end
    context "with an event which hit no one" do
      before do
        expect(@resolver).to receive(:resolve).and_return(:foo)
      end
      it "should return :foo" do
        expect(@handler.handle_press_event(@event)).to be :foo
      end
    end
    context "with an event which hit no one and 2 stroke @bind_resolver" do
      before do
        expect(@resolver).to receive(:resolve).and_return(:foo)
        allow(@resolver).to receive(:two_stroke?) { true }
      end
      it "should return :foo" do
        expect(@handler.handle_press_event(@event)).to be :foo
        # TODO check to change @bind_resolver to @default_bind_resolver or @window_bind_resolver
      end
    end
  end

  describe "#handle_release_event" do
    before do
      event = Revdev::InputEvent.new nil, Revdev::EV_KEY, 1, 1
      @key_bind = KeyBind.new [0, 1], [2, 3]
      expect(@resolver).to receive(:resolve).and_return(@key_bind)
      expect(@ope).to receive(:press_key).with(2)
      expect(@ope).to receive(:press_key).with(3)
      expect(@ope).to receive(:release_key).with(0)
      @handler.handle_press_event event
    end
    context "with an event which can be found in @active_bind_set" do
      it "should return :ignore, update @active_bind_set and send messages to @ope" do
        expect(@ope).to receive(:release_key).with(2)
        expect(@ope).to receive(:release_key).with(3)
        @event = Revdev::InputEvent.new nil, Revdev::EV_KEY, 1, 0
        expect(@handler.handle_release_event(@event)).to be :ignore
        expect(@handler.active_bind_set).to be_empty
      end
      it "should return :ignore and update @active_bind_set" do
        expect(@ope).to receive(:release_key).with(2)
        expect(@ope).to receive(:release_key).with(3)
        @event = Revdev::InputEvent.new nil, Revdev::EV_KEY, 0, 0
        expect(@handler.handle_release_event(@event)).to be :ignore
        expect(@handler.active_bind_set).to be_empty
      end
    end
    context "with an event which can not be found in @active_bind_set" do
      it "should return :through" do
        @event = Revdev::InputEvent.new nil, Revdev::EV_KEY, 10, 0
        expect(@handler.handle_release_event(@event)).to be :through
      end
    end
  end

  describe "#handle_pressing_event" do
    context "with an pressing event and empty @active_bind_set" do
      it "should return :through" do
        @event = Revdev::InputEvent.new nil, Revdev::EV_KEY, 1, 2
        expect(@handler.handle_pressing_event(@event)).to be :through
      end
    end
    context "with an pressing event and @active_bind_set which have length:1" do
      before do
        event = Revdev::InputEvent.new nil, Revdev::EV_KEY, 1, 1
        @key_bind = KeyBind.new [0,1], [2,3]
        expect(@resolver).to receive(:resolve).and_return(@key_bind)
        expect(@ope).to receive(:press_key).with(2)
        expect(@ope).to receive(:press_key).with(3)
        expect(@ope).to receive(:release_key).with(0)
        @handler.handle_press_event event
      end
      it "should return :ignore and send messages to @operator" do
        expect(@ope).to receive(:pressing_key).with(2)
        expect(@ope).to receive(:pressing_key).with(3)
        @event = Revdev::InputEvent.new nil, Revdev::EV_KEY, 1, 2
        expect(@handler.handle_pressing_event(@event)).to be :ignore
      end
    end
  end

  describe '#active_window_changed' do
    before do
      @window = double ActiveWindowX::Window
      allow(@window).to receive(:app_name) { 'qux' }
      @resolver2 = double BindResolver
      allow(BindResolver).to receive(:new) { @resolver2 }
    end
    context 'with a Window, which contains "foo" in the title,' do
      before do
        allow(@window).to receive(:title) { 'foobar' }
        @handler.window nil, /foo/ do
          # noop
        end
      end
      it 'should change @bind_resolver' do
        resolver = @handler.bind_resolver
        @handler.active_window_changed(@window)
        expect(@handler.bind_resolver).to_not eq resolver
      end
    end
    context 'with a Window, which does not contain "foo" in the title,' do
      before do
        expect(@window).to receive(:title) { 'barbaz' };
        @handler.window nil, /foo/ do
        end
      end
      it 'should not change @bind_resolver' do
        resolver = @handler.bind_resolver
        @handler.active_window_changed(@window)
        expect(@handler.bind_resolver).to eq resolver
      end
    end
  end
end
