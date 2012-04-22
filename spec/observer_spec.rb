# -*- coding:utf-8; mode:ruby; -*-

require 'rbindkeys'

include Rbindkeys

describe Observer do
  context "normal" do
    before do
      mock_dev = mock(Rbindkeys::Device)
      Rbindkeys::Device.stub!(:new).and_return(mock_dev)

      mock_vdev = mock(Rbindkeys::VirtualDevice)
      Rbindkeys::VirtualDevice.stub!(:new).and_return(mock_vdev)
    end

    describe 'Observer#new' do
      context 'with valid device and config' do

        it "is constructed" do
          o = Observer.new "spec/config.rb", "/dev/input/event2"
        end

      end
    end

    describe 'Observ#parse_code' do
      before do
        @observer = Observer.new "spec/config.rb", "/dev/input/event2"
      end

      context 'with Fixnum' do
        it "should return Fixnum" do
          num = 0
          @observer.parse_code(num).should == num
        end
      end

      context 'with valid Symbol' do
        it "should return Fixnum" do
          sym = :KEY_CAPSLOCK
          @observer.parse_code(sym).should == Revdev.const_get(sym)
        end
      end
      context 'with unknown Symbol' do
        it "should raise NameError" do
          sym = :KEY_FOO
          begin
            @observer.parse_code(sym).should
            violated "to raise no error"
          rescue => e
            e.class.should == NameError
          end
        end
      end

      context 'with valid Array' do
        it "should return Array of Fixnum" do
          arr = [:KEY_CAPSLOCK, :KEY_RIGHT]
          @observer.parse_code(arr).should ==
            [:KEY_CAPSLOCK, :KEY_RIGHT].map{|s| Revdev.const_get s}

          arr = [[:KEY_CAPSLOCK, :KEY_RIGHT], :KEY_F]
          expected =
            [[Revdev.const_get(:KEY_CAPSLOCK), Revdev.const_get(:KEY_RIGHT)],
             Revdev.const_get(:KEY_F)]
          @observer.parse_code(arr).should == expected
        end
      end
    end
  end
end
