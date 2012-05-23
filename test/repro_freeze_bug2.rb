# a repro code (see repro_freeze_bug.rb)

require 'thread'

require 'rubygems'
require 'active_window_x'
require 'ruinput'

@listener = ActiveWindowX::EventListener.new
Thread.new do
  p @listener.listen 1
end

file = open '/dev/null', 'w'
file.syswrite 'foo'
