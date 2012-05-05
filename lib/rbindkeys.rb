# -*- coding:undecided-unix; mode:ruby; -*-

require "rubygems"
require "rbindkeys/version"
require "rbindkeys/log_utils"

require "rbindkeys/key_bind"
require "rbindkeys/bind_tree"
require "rbindkeys/observer"
require "rbindkeys/device"
require "rbindkeys/virtual_device"

require "rbindkeys/device_operator"
require "rbindkeys/key_event_handler"
require "rbindkeys/bind_resolver"
require "rbindkeys/fix_resolver"

module Rbindkeys

  class BindTree; end
  class Observer; end
  class Devicie; end
  class VirtualDevice; end

  class DeviceOperator; end
  class KeyEventHandler; end
  class BindResolver; end
  class FixResolver; end

  class DuplicateNodeError < ArgumentError; end
  class UnknownKeyValue < Exception; end
end
