# -*- coding:utf-8; mode:ruby; -*-

require 'rbindkeys'
require 'evdev'

include Rbindkeys

describe CLI do
  describe '#.main' do
    context ', when ARGV is empty,' do
      before do
        @stdout = StringIO.new
        # stub(STDOUT){@stdout}
        ARGV = []
      end
      it 'shoud exit with code 1' do
        expect { CLI::main }.to raise_error do |e|
          e.should be_a SystemExit
          e.status.should == 1
        end
      end
    end
    context ', when ARGV have an argument,' do
      before do
        ARGV = ['foo']
        Observer.should_receive(:new){mock Observer}
      end
      it 'should call Observer#new ' do
        config = CLI::config
        CLI::main
        CLI::config.should == config
      end
    end
    context ', when ARGV have an option (--evdev-list)' do
    end
    context ', when ARGV have an invalid option (--config)' do
      before do
        ARGV = ['--config']
      end
      it 'should exit with code 1' do
        expect { CLI::main }.to raise_error do |e|
          e.should be_a SystemExit
          e.status.should == 1
        end
      end
    end
    context ', when ARGV have an option (--config) and an event device' do
    end
  end
end
