# -*- coding:utf-8; mode:ruby; -*-

require 'rbindkeys'
require 'revdev'

include Rbindkeys

describe CLI do
  describe '#.main' do
    context ', when ARGV is empty,' do
      before do
        @args = []
      end
      it 'shoud exit with code 1' do
        expect { CLI::main @args }.to raise_error do |e|
          expect(e).to be_a SystemExit
          expect(e.status).to eq 1
        end
      end
    end
    context ', when ARGV have an argument,' do
      before do
        @args = ['foo']
        @observer = double Observer
        expect(Observer).to receive(:new) { @observer }
        expect(@observer).to receive(:start) { nil }
      end
      it 'should call Observer#new#start' do
        config = CLI::config
        CLI::main @args
        expect(CLI::config).to eq config
      end
    end
    context ', when ARGV have an invalid option (--config),' do
      before do
        @args = ['--config']
      end
      it 'should exit with code 1' do
        expect { CLI::main @args }.to raise_error do |e|
          expect(e).to be_a SystemExit
          expect(e.status).to eq 1
        end
      end
    end
    context ', when ARGV have an option (--config) and an event device,' do
      before do
        @config = 'a_config_file'
        @args = ['--config', @config, 'foodev']
        @observer = double Observer
        expect(Observer).to receive(:new) { @observer }
        expect(@observer).to receive(:start) { nil }
      end
      it 'should call Observer#new#start ' do
        CLI::main @args
        expect(CLI::config).to eq @config
      end
    end
    context ', when ARGV have an option (--evdev-list),' do
      before do
        @args = ['--evdev-list']
        @evdev = double Revdev::EventDevice
        @id = double Object
        allow(@evdev).to receive(:device_name) { "foo" }
        allow(@evdev).to receive(:device_id) { @id }
        allow(@id).to receive(:hr_bustype) { 'bar' }
        allow(Revdev::EventDevice).to receive(:new) { @evdev }
        expect(Dir).to receive(:glob).with(CLI::EVDEVS)
                        .and_return(['/dev/input/event4',
                                     '/dev/input/event2',
                                     '/dev/input/event13'])
      end
      it 'should pring device info' do
        CLI::main @args
      end
    end
  end
end
