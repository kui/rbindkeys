# -*- coding:utf-8; mode:ruby; -*-

require 'rbindkeys'
require 'revdev'

include Rbindkeys

describe DeviceOperator do
  before do
    @dev = mock Device
    @vdev = mock VirtualDevice
    @operator = DeviceOperator.new @dev, @vdev
  end

  describe "#send_key" do
    context "with a code and a press value" do
      before do
        @code = 10
        @value = 1
      end
      it "should call #send_event and update @pressed_key_set" do
        @operator.should_receive(:send_event).with(Revdev::EV_KEY,@code,@value)
        @operator.send_key @code, @value
        @operator.pressed_key_set.should == [10]
      end
    end
    context "with a code and a release value" do
      before do
        @code = 10
        @value = 0

        # press code:10
        @operator.should_receive(:send_event).with(Revdev::EV_KEY,@code,1)
        @operator.send_key @code, 1
      end
      it "should call #send_event and update @pressed_key_set" do
        @operator.should_receive(:send_event).with(Revdev::EV_KEY,@code,@value)
        @operator.send_key @code, @value
        @operator.pressed_key_set.should == []
      end
    end
  end

  context "#send_event" do
    context "with normal values" do
      before do
        @type = Revdev::EV_KEY
        @code = 10
        @value = 1
      end
      it "should send a #write_input_event to @vdev" do
        @vdev.should_receive(:write_input_event) do |ie|
          p '---------------------------------'
          ie.code.should == @code
          10
        end
        @operator.send_event @type, @code, @value
      end
    end
    context "with an input event" do
      before do
        @ie = Revdev::InputEvent.new nil, Revdev::EV_KEY, 10, 1
      end
      it "should send a #write_input_event to @vdev" do
        @vdev.should_receive(:write_input_event) do |ie|
          ie.should == @ie
          10
        end
        @operator.send_event @ie
      end
    end
  end

end
