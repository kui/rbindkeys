# a repro code for bloking on uinput.write_input_event forever.
# this blocking was occured when the writing was called with x window system operation
# on the other thread.


require 'thread'

require 'rubygems'
require 'active_window_x'
require 'ruinput'

@listener = ActiveWindowX::EventListener.new

uinput = Ruinput::UinputDevice.new
uinput.create

Thread.new do
  p @listener.listen 1
end

include Revdev
while true do
  puts "main:\t#{@listener.active_window and @listener.active_window.title}"
  uinput.write_input_event InputEvent.new nil, EV_MSC, MSC_SCAN, 0 # block !!!
  sleep 5
end
