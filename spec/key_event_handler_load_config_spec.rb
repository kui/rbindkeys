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
    @dev = mock(Rbindkeys::Device)
    @vdev = mock(Rbindkeys::VirtualDevice)
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
      @handler = KeyEventHandler.new @dev, @vdev
    end

    describe "KeyEventHandler#load_config" do
      it "construct @pre_bind_key_set and @bind_key_set" do
        @handler.load_config $config
        @handler.pre_bind_key.size.should == 1
        @handler.pre_bind_key.size.should == 2
      end
    end
  end
end
