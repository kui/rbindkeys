# -*- coding:utf-8; mode:ruby; -*-

require 'rbindkeys'

include Rbindkeys

describe CLI do
  describe '#.main' do
    context ', when ARGV is empty,' do
      before do
        @stdout = StringIO.new
        stub(ARGV){[]}
        # stub(STDOUT){@stdout}
      end
      it 'shoud exit with code 1' do
        expect { CLI::main }.to raise_error do |e|
          e.should be_a SystemExit
          e.status.should == 1
        end
      end
    end
    context ', when ARGV have an event device,' do
    end
    context ', when ARGV have an invalid event device' do
    end
    context ', when ARGV have an option (--evdev-list)' do
    end
    context ', when ARGV have an option (--config) and an event device' do
    end
  end
end
