# Rbindkeys

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

	gem 'rbindkeys'

And then execute:

	$ bundle

Or install it yourself as:

	$ gem install rbindkeys

## Usage

1. `rbindkeys -e > ~/.rbindkeys.rb`
2. edit `~.rbindkeys.rb`
3. select a keyboard device (see `rbindkeys --evdev-list`)
4. execute `rbindkeys /dev/input/event2` if you selected "/dev/input/event2"
   as a target keyboard

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## TODO

* write documents and publish on rubygem.org
* a daemonize script
* remove @two_storoke and add PrefixBindResolver class
* change BindResolver on input method system
* simplify config file ( `bind_key [:ctrl, :m], :enter`, `bind_key "ctrl+m", "enter"` )
* integrate ibus controller ( `bind_key "alt-grave", "toggle_ibus"` )
* notification when active a prefix key, changing ibus status, etc..
* fix bug
	* the enter key cannot be release when `rbindkey` is executed
