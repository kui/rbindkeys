# -*- coding:utf-8; mode:ruby; -*-

# bind :left_ctrl, :caps
# bind :caps, :left_ctrl

pre_bind_key KEY_CAPSLOCK, KEY_LEFTCTRL
pre_bind_key KEY_LEFTCTRL, KEY_CAPSLOCK

bind_key [KEY_LEFTCTRL, KEY_F], KEY_RIGHT
bind_key [KEY_LEFTCTRL, KEY_B], KEY_LEFT
bind_key [KEY_LEFTCTRL, KEY_P], KEY_UP
bind_key [KEY_LEFTCTRL, KEY_N], KEY_DOWN
bind_key [KEY_LEFTCTRL, KEY_A], KEY_HOME
bind_key [KEY_LEFTCTRL, KEY_E], KEY_END
bind_key [KEY_LEFTCTRL, KEY_V], KEY_PAGEDOWN
bind_key [KEY_LEFTALT, KEY_V], KEY_PAGEUP
bind_key [KEY_LEFTCTRL, KEY_D], KEY_DELETE
bind_key [KEY_LEFTCTRL, KEY_H], KEY_BACKSPACE
bind_key [KEY_LEFTCTRL, KEY_M], KEY_ENTER
bind_key [KEY_LEFTCTRL, KEY_I], KEY_TAB

# bind_event KEY_LEFTCTRL do |event, context|
#   led LED_CAPSL, event.value
#   send_key KEY_CAPSLOCK
# end
