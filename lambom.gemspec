# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "lambom/version"

Gem::Specification.new do |s|
  s.name        = 'lambom'
  s.version     = Lambom::VERSION
  s.date        = '2013-12-23'
  s.summary     = "Tool to apply riyic configurations"
  s.description = "Riyic is a server configuration service based on chef (http://riyic.com). The lambom gem is a tool to apply, through chef-solo, your riyic configurations in your server"
  s.authors     = ["J. Gomez"]
  s.email       = 'alambike@gmail.com'
  s.require_paths = ["lib"]
  s.executables << 'lambom'
  s.files         = `git ls-files`.split($/)
  s.license       = 'Apache-2.0'

  s.add_runtime_dependency "oj","~> 2.0"
  s.add_runtime_dependency "mixlib-authentication","~> 1.3"
  s.add_runtime_dependency "mixlib-shellout","~> 1.3"

  s.add_development_dependency "rspec", "~> 2.0"

  s.homepage    =
    'https://github.com/RIYIC/lambom'
end
