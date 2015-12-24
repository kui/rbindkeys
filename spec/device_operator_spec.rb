# -*- coding:utf-8; mode:ruby; -*-

require 'rbindkeys'
require 'revdev'

include Rbindkeys

describe DeviceOperator do
  before do
    @dev = double Device
    @vdev = double VirtualDevice
    @operator = DeviceOperator.new @dev, @vdev
  end

  describe "#send_key" do
    context "with a code and a press value" do
      before do
        @code = 10
        @value = 1
      end
      it "should call #send_event" do
        expect(@operator).to receive(:send_event).with(Revdev::EV_KEY, @code, @value)
        @operator.send_key @code, @value
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
        expect(@vdev).to receive(:write_input_event) do |ie|
          expect(ie.code).to be @code
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
        expect(@vdev).to receive(:write_input_event) do |ie|
          expect(ie).to be @ie
          10
        end
        @operator.send_event @ie
      end
    end
  end

end
