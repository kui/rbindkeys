# -*- coding:utf-8; mode:ruby; -*-

require 'rbindkeys'

include Rbindkeys

describe Observer do
  context "normal" do
    describe 'Observer#new' do
      context 'with valid device and config' do

        before do
          mock_dev = mock(Rbindkeys::Device)
          Rbindkeys::Device.stub!(:new).and_return(mock_dev)

          mock_vdev = mock(Rbindkeys::VirtualDevice)
          Rbindkeys::VirtualDevice.stub!(:new).and_return(mock_vdev)
        end

        it "is constructed" do
          o = Observer.new "spec/config.rb", "/dev/input/event2"
          p o
        end

      end
    end
  end
end
