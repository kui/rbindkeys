# -*- coding:utf-8; mode:ruby; -*-

## settings
@swap_ctrl_with_caps = true

##

if @swap_ctrl_with_caps
  pre_bind_key KEY_CAPSLOCK, KEY_LEFTCTRL
  pre_bind_key KEY_LEFTCTRL, KEY_CAPSLOCK
end

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

# binds related kill-ring
bind_key [KEY_LEFTCTRL, KEY_W], [KEY_LEFTCTRL,KEY_X]
bind_key [KEY_LEFTALT, KEY_W], [KEY_LEFTCTRL,KEY_C]
bind_key [KEY_LEFTCTRL, KEY_Y], [KEY_LEFTCTRL,KEY_V]

# 2 stroke binds
bind_prefix_key [KEY_LEFTCTRL, KEY_X] do
  bind_key [KEY_K], [KEY_LEFTCTRL, KEY_W]
  bind_key [KEY_S], [KEY_LEFTCTRL, KEY_S]
  bind_key [KEY_B], [KEY_LEFTCTRL, KEY_TAB]
end
