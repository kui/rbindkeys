# -*- coding:utf-8; mode:ruby; -*-

require 'rbindkeys'
require 'fileutils'
require 'revdev'

include Rbindkeys

$tmp_dir = 'tmp'

describe KeyEventHandler do
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

  describe "#bind_prefix_key" do
    before do
      @defval = :hoge
      @bind_set = []
      res = mock Rbindkeys::BindResolver

      # define stubs
      res.stub(:default_value) { @defval }
      res.stub(:bind) do |i, o|
        @bind_set << [i, o]
      end
      res.stub(:resolve) do |input, pressed_key_set|
        if input == 10
          BindResolver.new
        else
          @defval
        end
      end
      Rbindkeys::BindResolver.stub!(:new).and_return(res)

      @handler = KeyEventHandler.new @dev, @vdev
    end

    context "add a new prefix key" do
      it "construct @bind_set" do
        @handler.bind_prefix_key [0,1] do
          @handler.bind_key 2, 3
        end
        @bind_set.length.should == 2
        @bind_set.include?([[2],[3]]).should be_true
      end
    end
    context "add a existing prefix key" do
      it "construct @bind_set" do
        @handler.bind_prefix_key [0,10] do
          @handler.bind_key 2, 3
        end
        @bind_set.length.should == 1
        @bind_set.include?([[2],[3]]).should be_true
      end
    end
  end

  describe "KeyEventHandler#load_config" do
    $config = File.join($tmp_dir, 'config.rb')

    before :all do
      open $config, 'w' do |f|
        f.write <<-EOF
pre_bind_key KEY_CAPSLOCK, KEY_LEFTCTRL
bind_key [KEY_LEFTCTRL,KEY_F], KEY_RIGHT
bind_key [KEY_LEFTCTRL,KEY_W], [KEY_LEFTCTRL,KEY_X]
bind_prefix_key [KEY_LEFTCTRL,KEY_X] do
  bind_key KEY_K, [KEY_LEFTCTRL, KEY_W]
end
EOF
      end
    end

    before do
      @bind_set = []
      res = mock Rbindkeys::BindResolver
      res.stub(:bind) do |i, o|
        @bind_set << [i, o]
      end
      Rbindkeys::BindResolver.stub!(:new).and_return(res)
      @handler = KeyEventHandler.new @dev, @vdev
    end

    it "construct @pre_bind_key_set and @bind_key_set" do
      @handler.load_config $config
      @handler.pre_bind_resolver.size.should == 1
      @bind_set.length.should == 3
      @bind_set[0][1].should == [Revdev::KEY_RIGHT]
      p @bind_set
    end
  end
end
