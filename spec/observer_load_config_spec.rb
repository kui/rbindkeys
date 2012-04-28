# -*- coding:utf-8; mode:ruby; -*-

require 'rbindkeys'
require 'fileutils'

include Rbindkeys

describe Observer do
  before :all do
    FileUtils.mkdir 'tmp'
  end

  after :all do
    FileUtils.rm_r 'tmp'
  end

  before do
    mock_dev = mock(Rbindkeys::Device)
    Rbindkeys::Device.stub!(:new).and_return(mock_dev)

    mock_vdev = mock(Rbindkeys::VirtualDevice)
    Rbindkeys::VirtualDevice.stub!(:new).and_return(mock_vdev)
  end

  describe "#load_config" do
    it "' pre_keybinds have valid Objects" do
      #TODO
    end
  end
end
