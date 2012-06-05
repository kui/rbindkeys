# -*- coding:utf-8; mode:ruby; -*-

## user settings

# if you use a keyboard which have a left ctrl key at the left of "A" key,
# then you must set false
@swap_left_ctrl_with_caps = true

# for apple keyboard
@swap_left_opt_with_left_cmd = true

##

if @swap_left_ctrl_with_caps
  pre_bind_key KEY_CAPSLOCK, KEY_LEFTCTRL
  pre_bind_key KEY_LEFTCTRL, KEY_CAPSLOCK
end

if @swap_left_opt_with_left_cmd
  pre_bind_key KEY_LEFTMETA, KEY_LEFTALT
  pre_bind_key KEY_LEFTALT, KEY_LEFTMETA
end

# cursor move
bind_key [KEY_LEFTCTRL, KEY_F], KEY_RIGHT
bind_key [KEY_LEFTCTRL, KEY_B], KEY_LEFT
bind_key [KEY_LEFTCTRL, KEY_P], KEY_UP
bind_key [KEY_LEFTCTRL, KEY_N], KEY_DOWN
bind_key [KEY_LEFTCTRL, KEY_A], KEY_HOME
bind_key [KEY_LEFTCTRL, KEY_E], KEY_END

# page scroll
bind_key [KEY_LEFTCTRL, KEY_V], KEY_PAGEDOWN
bind_key [KEY_LEFTALT, KEY_V], KEY_PAGEUP

# edit
bind_key [KEY_LEFTCTRL, KEY_D], KEY_DELETE
bind_key [KEY_LEFTCTRL, KEY_H], KEY_BACKSPACE
bind_key [KEY_LEFTCTRL, KEY_M], KEY_ENTER
bind_key [KEY_LEFTCTRL, KEY_I], KEY_TAB
bind_key [KEY_LEFTCTRL, KEY_LEFTBRACE], KEY_ESC

# give a block sample
@caps_led_state = 0
bind_key KEY_CAPSLOCK do |event, operator|
  @caps_led_state = @caps_led_state ^ 1
  puts "########## CAPSLOCK LED #{@caps_led_state.zero? ? 'off' : 'on'} ##########"
  operator.send_event EV_LED, LED_CAPSL, @caps_led_state
end

# cut, copy and paste
bind_key [KEY_LEFTCTRL, KEY_W], [KEY_LEFTCTRL,KEY_X]
bind_key [KEY_LEFTALT, KEY_W], [KEY_LEFTCTRL,KEY_C]
bind_key [KEY_LEFTCTRL, KEY_Y], [KEY_LEFTCTRL,KEY_V]

# kill line
bind_key [KEY_LEFTCTRL, KEY_K] do |event, operator|
  # Shift+End : select text to end of line
  operator.press_key KEY_LEFTSHIFT
  operator.press_key KEY_END
  operator.release_key KEY_END
  operator.release_key KEY_LEFTSHIFT

  # Ctrl+x : cut
  operator.press_key KEY_LEFTCTRL
  operator.press_key KEY_X
  operator.release_key KEY_X
  operator.release_key KEY_LEFTCTRL
end

# 2 stroke key binds
# if your input was not hit any bind_key, the input will be ignored
bind_prefix_key [KEY_LEFTCTRL, KEY_X] do

  # C-xk: close tab, etc.
  bind_key KEY_K, [KEY_LEFTCTRL, KEY_W]

  # C-xC-s: save
  bind_key [KEY_LEFTCTRL, KEY_S], [KEY_LEFTCTRL, KEY_S]

  # C-xb: next tab, etc.
  bind_key KEY_B, [KEY_LEFTCTRL, KEY_TAB]

  # C-xC-g: ignore C-x prefix bind
  bind_key [KEY_LEFTCTRL, KEY_G], :ignore

  # C-xC-c: close window
  bind_key [KEY_LEFTCTRL, KEY_C], [KEY_LEFTALT, KEY_F4]
end

# settings per window class (or title)

# through all key inputs if active
window(:through, :class => /gnome-terminal/)

# add new bind_key to default binds
window(@default_bind_resolver, :class => /google-chrome/) do
  bind_key [KEY_LEFTCTRL, KEY_S], [KEY_LEFTCTRL, KEY_F]
end
