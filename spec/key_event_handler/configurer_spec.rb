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
    @ope = mock DeviceOperator
  end

  describe "bind keys methods" do

    before do
      @defval = :hoge
      @bind_set = []
      @res = mock Rbindkeys::BindResolver

      # define stubs
      @res.stub(:bind) do |i, o|
        @bind_set << [i, o]
      end
      @res.stub(:resolve) do |input, pressed_key_set|
        if input == 10
          BindResolver.new
        else
          @defval
        end
      end
      @res.stub(:just_resolve) do |input, pressed_key_set|
        if input == 10
          BindResolver.new
        else
          nil
        end
      end
      @res.stub(:kind_of?) do |klass|
        klass == Rbindkeys::BindResolver
      end
      Rbindkeys::BindResolver.stub!(:new).and_return(@res)

      @handler = KeyEventHandler.new @ope
    end

    describe KeyEventHandler, "#pre_bind_key" do
      context "with a bind" do
        it "map the bind to @pre_bind_resolver" do
          @handler.pre_bind_key 1, 0
          @handler.pre_bind_resolver[1].should == 0
        end
      end
      context "with duplicated binds" do
        it "should raise a DuplicatedNodeError" do
          @handler.pre_bind_key 1, 0
          lambda{ @handler.pre_bind_key(1, 2) }.should raise_error(DuplicateNodeError)
        end
      end
    end

    describe KeyEventHandler, "#bind_key" do
      context "with two Fixnum" do
        it "construct @bind_set" do
          @handler.bind_key 0, 1
          @bind_set.should == [[[0],[1]]]
        end
      end
      context "with two Arrays" do
        it "construct @bind_set" do
          @handler.bind_key [0, 1], [2, 3]
          @bind_set.should == [[[0, 1], [2, 3]]]
        end
      end
      context "with an Array and a KeyResolver" do
        it "construct @bind_set" do
          @handler.bind_key [0,1], @res
          @bind_set.should == [[[0,1], @res]]
        end
      end
      context "with an Array and a block" do
        it "construct @bind_set" do
          @handler.bind_key [0,1] do
            p 'foo'
          end
          @bind_set.first[1].class.should == Proc
        end
      end
      context "with mix classes" do
        it "construct @bind_set" do
          @handler.bind_key 1, [2, 3]
          @handler.bind_key [2, 3], 4
          @bind_set.should == [[[1], [2, 3]], [[2, 3], [4]]]
        end
      end
      context "with invalid args" do
        it "raise some error" do
          lambda{@handler.bind_key [1], [[[2]]]}.should raise_error
        end
      end
    end

    describe KeyEventHandler, "#bind_prefix_key" do
      context "with a new prefix key" do
        it "construct @bind_set" do
          @handler.bind_prefix_key [0,1] do
            @handler.bind_key 2, 3
          end
          @bind_set.length.should == 2
          @bind_set.include?([[2],[3]]).should be_true
        end
      end
      context "with a existing prefix key" do
        it "should construct @bind_set" do
          @handler.bind_prefix_key [0,10] do
            @handler.bind_key 2, 3
          end
          @bind_set.length.should == 1
          @bind_set.include?([[2],[3]]).should be_true
        end
      end
    end

    describe KeyEventHandler, "#window" do
      context 'with invalid arg' do
        it 'should raise ArgumentError' do
          lambda { @handler.window(nil, "foo") }.should raise_error
          lambda { @handler.window(nil, :class => "bar") }.should raise_error
        end
      end
      context 'with nil and a regex' do
        it 'should return the BindResolver and added it to @window_bind_resolver_map' do
          size = @handler.window_bind_resolver_map.size
          res = @handler.window(nil, /foo/)
          res.should be_a BindResolver
          (@handler.window_bind_resolver_map.size - size).should == 1
          @handler.window_bind_resolver_map.value?(res).should be_true
        end
      end
      context 'with nil and a Hash having :class key' do
        it 'should return the BindResolver and added it to @window_bind_resolver_map' do
          size = @handler.window_bind_resolver_map.size
          res = @handler.window(nil, :class => /foo/)
          res.should be_a BindResolver
          (@handler.window_bind_resolver_map.size - size).should == 1
          @handler.window_bind_resolver_map.value?(res).should be_true
        end
      end
      context 'with a BindResolver and a regex' do
        before do
          @arg_resolver = mock BindResolver
          @arg_resolver.stub(:kind_of?).and_return(false)
          @arg_resolver.stub(:kind_of?).with(BindResolver).and_return(true)
        end
        it 'should return the BindResolver and added it to @window_bind_resolver_map' do
          size = @handler.window_bind_resolver_map.size
          res = @handler.window(@arg_resolver, /foo/)
          res.should be_a BindResolver
          (@handler.window_bind_resolver_map.size - size).should == 1
          @handler.window_bind_resolver_map.value?(res).should be_true
        end
      end
    end

    describe "KeyEventHandler#load_config" do
      before :all do
        @config = File.join $tmp_dir, 'config'
        open @config, 'w' do |f|
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
      it "construct @pre_bind_key_set and @bind_key_set" do
        @handler.load_config @config
        @handler.pre_bind_resolver.size.should == 1
        @bind_set.length.should == 4
        @bind_set[0][1].should == [Revdev::KEY_RIGHT]
        @bind_set[1][1].should == [Revdev::KEY_LEFTCTRL, Revdev::KEY_X]
        @bind_set[2][1].should == @res
        @bind_set[3][1].should == [Revdev::KEY_LEFTCTRL, Revdev::KEY_W]
      end
    end
  end
end
