# -*- coding:utf-8; mode:ruby; -*-

require 'rubygems'
require 'rbindkeys/version'
require 'rbindkeys/log_utils'

require 'rbindkeys/key_bind'
require 'rbindkeys/bind_tree'
require 'rbindkeys/observer'
require 'rbindkeys/device'
require 'rbindkeys/virtual_device'

require 'rbindkeys/device_operator'
require 'rbindkeys/key_event_handler'
require 'rbindkeys/window_matcher'
require 'rbindkeys/bind_resolver'
require 'rbindkeys/fix_resolver'

require 'rbindkeys/cli'

module Rbindkeys
  class DuplicateNodeError < ArgumentError; end
  class UnknownKeyValue < Exception; end
end
