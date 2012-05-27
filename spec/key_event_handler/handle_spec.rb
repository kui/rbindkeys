# -*- coding:utf-8; mode:ruby; -*-

require 'rbindkeys'
require 'revdev'

include Rbindkeys

describe KeyEventHandler do
  before do
    @ope = mock DeviceOperator
    @ope.stub(:pressed_key_set){ [] }
    @resolver = mock BindResolver
    @resolver2 = BindResolver.new
    BindResolver.stub!(:new){@resolver}
    @resolver.stub!(:two_stroke?){false}

    @handler = KeyEventHandler.new @ope
  end

  describe "#handle" do
    context "with a pressed event" do
      before do
        @event = Revdev::InputEvent.new nil, Revdev::EV_KEY, Revdev::KEY_K, 1
      end
      context "if handle_pressed_event return :through" do
        before do
          @handler.should_receive(:handle_press_event){:through}
        end
        it "shoud send @event" do
          @ope.should_receive(:send_event).with(@event)
          @handler.handle @event
        end
      end

      context "if handle_pressed_event return :ignore" do
        before do
          @handler.should_receive(:handle_press_event){:ignore}
        end
        it "shoud ignore @event" do
          @ope.should_not_receive(:send_event)
          @handler.handle @event
        end
      end
    end

    context "with a released event" do
      before do
        @event = Revdev::InputEvent.new nil, Revdev::EV_KEY, Revdev::KEY_K, 0
        @handler.should_receive(:handle_release_event){:ignore}
      end
      it "shoud ignore @event" do
        @ope.should_not_receive(:send_event)
        @handler.handle @event
      end
    end

    context "with a pressing event" do
      before do
        @event = Revdev::InputEvent.new nil, Revdev::EV_KEY, Revdev::KEY_K, 2
        @handler.should_receive(:handle_pressing_event){:ignore}
      end
      it "shoud ignore @event" do
        @ope.should_not_receive(:send_event)
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
        @resolver.should_receive(:resolve).and_return(@key_bind)
      end
      it "should return :ignore, send messages to @ope and update @active_bind_set" do
        @ope.should_receive(:press_key).with(2)
        @ope.should_receive(:press_key).with(3)
        @ope.should_receive(:release_key).with(0)
        @handler.handle_press_event(@event).should == :ignore
        @handler.active_bind_set.should == [@key_bind]
      end
    end
    context "with an event which hit a BindResolver" do
      before do
        @key_bind = KeyBind.new [0,1], @resolver2
        @resolver.should_receive(:resolve).and_return(@key_bind)
      end
      it "should return :ignore and update @bind_resolver" do
        @handler.handle_press_event(@event).should == :ignore
        @handler.bind_resolver.should == @resolver2
      end
    end
    context "with an event which hit a Proc" do
      before do
        @proc = proc {
          :foo
        }
        @key_bind = KeyBind.new [0,1], @proc
        @resolver.should_receive(:resolve).and_return(@key_bind)
      end
      it "should return :ignore and update @bind_resolver" do
        @handler.handle_press_event(@event).should == :foo
      end
    end
    context "with an event which hit no one" do
      before do
        @resolver.should_receive(:resolve).and_return(:foo)
      end
      it "should return :foo" do
        @handler.handle_press_event(@event).should == :foo
      end
    end
    context "with an event which hit no one and 2 stroke @bind_resolver" do
      before do
        @resolver.should_receive(:resolve).and_return(:foo)
        @resolver.stub(:two_stroke?){true}
      end
      it "should return :foo" do
        @handler.handle_press_event(@event).should == :foo
        # TODO check to change @bind_resolver to @default_bind_resolver or @window_bind_resolver
      end
    end
  end

  describe "#handle_release_event" do
    before do
      event = Revdev::InputEvent.new nil, Revdev::EV_KEY, 1, 1
      @key_bind = KeyBind.new [0,1], [2,3]
      @resolver.should_receive(:resolve).and_return(@key_bind)
      @ope.should_receive(:press_key).with(2)
      @ope.should_receive(:press_key).with(3)
      @ope.should_receive(:release_key).with(0)
      @handler.handle_press_event event
    end
    context "with an event which can be found in @active_bind_set" do
      it "should return :ignore, update @active_bind_set and send messages to @ope" do
        @ope.should_receive(:release_key).with(2)
        @ope.should_receive(:release_key).with(3)
        @event = Revdev::InputEvent.new nil, Revdev::EV_KEY, 1, 0
        @handler.handle_release_event(@event).should == :ignore
        @handler.active_bind_set.empty?.should be_true
      end
      it "should return :ignore and update @active_bind_set" do
        @ope.should_receive(:release_key).with(2)
        @ope.should_receive(:release_key).with(3)
        @event = Revdev::InputEvent.new nil, Revdev::EV_KEY, 0, 0
        @handler.handle_release_event(@event).should == :ignore
        @handler.active_bind_set.empty?.should be_true
      end
    end
    context "with an event which can not be found in @active_bind_set" do
      it "should return :through" do
        @event = Revdev::InputEvent.new nil, Revdev::EV_KEY, 10, 0
        @handler.handle_release_event(@event).should == :through
      end
    end
  end

  describe "#handle_pressing_event" do
    context "with an pressing event and empty @active_bind_set" do
      it "should return :through" do
        @event = Revdev::InputEvent.new nil, Revdev::EV_KEY, 1, 2
        @handler.handle_pressing_event(@event).should == :through
      end
    end
    context "with an pressing event and @active_bind_set which have length:1" do
      before do
        event = Revdev::InputEvent.new nil, Revdev::EV_KEY, 1, 1
        @key_bind = KeyBind.new [0,1], [2,3]
        @resolver.should_receive(:resolve).and_return(@key_bind)
        @ope.should_receive(:press_key).with(2)
        @ope.should_receive(:press_key).with(3)
        @ope.should_receive(:release_key).with(0)
        @handler.handle_press_event event
      end
      it "should return :ignore and send messages to @operator" do
        @ope.should_receive(:pressing_key).with(2)
        @ope.should_receive(:pressing_key).with(3)
        @event = Revdev::InputEvent.new nil, Revdev::EV_KEY, 1, 2
        @handler.handle_pressing_event(@event).should == :ignore
      end
    end
  end

  describe '#active_window_changed' do
    before do
      @window = mock ActiveWindowX::Window
      @window.stub(:app_name).and_return('qux');
      @resolver2 = mock BindResolver
      BindResolver.stub!(:new){@resolver2}
    end
    context 'with a Window, which contains "foo" in the title,' do
      before do
        @window.stub(:title).and_return('foobar');
        @handler.window nil, /foo/ do
        end
      end
      it 'should change @bind_resolver' do
        puts "phoooooo"
        resolver = @handler.bind_resolver
        @handler.active_window_changed(@window)
        @handler.bind_resolver.should_not == resolver
      end
    end
    context 'with a Window, which does not contain "foo" in the title,' do
      before do
        @window.stub(:title).and_return('barbaz');
        @handler.window nil, /foo/ do
        end
      end
      it 'should not change @bind_resolver' do
        resolver = @handler.bind_resolver
        @handler.active_window_changed(@window)
        @handler.bind_resolver.should == resolver
      end
    end
  end

end
