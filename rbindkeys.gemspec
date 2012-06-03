# -*- coding:utf-8-unix; mode:ruby; -*-

require File.expand_path('../lib/rbindkeys/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Keiichiro Ui"]
  gem.email         = ["keiichiro.ui@gmail.com"]
  gem.description   = "key remap"
  gem.summary       = "key remap"
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "rbindkeys"
  gem.require_paths = ["lib"]
  gem.version       = Rbindkeys::VERSION

  gem.add_dependency 'revdev'
  gem.add_dependency 'ruinput'
  gem.add_dependency 'active_window_x'
  gem.add_development_dependency 'bundler'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec'

end
