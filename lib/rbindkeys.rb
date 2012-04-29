# -*- coding:undecided-unix; mode:ruby; -*-

require "rubygems"
require "rbindkeys/version"
require "rbindkeys/key_bind"
require "rbindkeys/bind_tree"
require "rbindkeys/observer"
require "rbindkeys/device"
require "rbindkeys/virtual_device"

require "rbindkeys/key_event_handler"
require "rbindkeys/bind_resolver"

module Rbindkeys

  DEFAULT_LOG_OUTPUT = STDIN

  class BindTree; end
  class Observer; end
  class Devicie; end
  class VirtualDevice; end

  class KeyEventHandler; end
  class BindResolver; end
end
