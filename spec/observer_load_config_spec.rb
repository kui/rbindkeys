# -*- coding:utf-8; mode:ruby; -*-

require 'rbindkeys'
require 'fileutils'

include Rbindkeys

$tmp_dir = 'tmp'

describe Observer do
  before :all do
    FileUtils.mkdir $tmp_dir
  end

  after :all do
    FileUtils.rm_r $tmp_dir
  end

  before do
    mock_dev = mock(Rbindkeys::Device)
    Rbindkeys::Device.stub!(:new).and_return(mock_dev)

    mock_vdev = mock(Rbindkeys::VirtualDevice)
    Rbindkeys::VirtualDevice.stub!(:new).and_return(mock_vdev)
  end

  context "simple keybinds" do
    $config = File.join($tmp_dir, 'config.rb')

    before :all do
      open $config, 'w' do |f|
        f.write <<-EOF
pre_bind_key KEY_CAPSLOCK, KEY_LEFTCTRL
bind_key [KEY_LEFTCTRL,KEY_F], KEY_RIGHT
bind_key [KEY_LEFTCTRL,KEY_W], [KEY_LEFTCTRL,KEY_X]
EOF
      end
    end

    before do
      @obs = Observer.new $config, "/dev/input/event2"
    end

    describe "Observer#load_config" do
      it "'s @pre_keybinds and @key_binds have valid values" do
        @obs.load_config
        @obs.pre_key_binds.should ==
          {Revdev::KEY_CAPSLOCK => Revdev::KEY_LEFTCTRL}
        @obs.key_binds.should be_kind_of BindTree
      end
    end
  end
end
