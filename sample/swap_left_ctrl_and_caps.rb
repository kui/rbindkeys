# -*- coding:utf-8; mode:ruby; -*-

# bind :left_ctrl, :caps
# bind :caps, :left_ctrl

bind_key KEY_CAPSLOCK, KEY_LEFTCTRL

bind_key KEY_LEFTCTRL do |event, context|
  light_on LED_CAPSL
  send_key KEY_CAPSLOCK
end
