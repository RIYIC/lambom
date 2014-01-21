# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "lambom/version"

Gem::Specification.new do |s|
  s.name        = 'lambom'
  s.version     = Lambom::VERSION
  s.date        = '2014-01-21'
  s.summary     = "Tool to configure servers based on chef-solo and berkshelf"
  s.description = <<-EOF
Riyic is a server configuration service based on chef (http://riyic.com).
The lambom gem is a tool to apply chef configurations generated in the riyic service, or defined in a pair of plain text files 
(a json attributes file where details server configuration and a berkshelf file where specify cookbooks restrictions and sources).
EOF

  s.authors     = ["J. Gomez"]
  s.email       = 'alambike@gmail.com'
  s.require_paths = ["lib"]
  s.executables << 'lambom'
  s.files         = `git ls-files`.split($/)
  s.license       = 'Apache-2.0'

  s.add_runtime_dependency "oj","~> 2.5.4"
  s.add_runtime_dependency "mixlib-authentication","~> 1.3.0"
  s.add_runtime_dependency "mixlib-shellout","~> 1.3.0"
  s.add_runtime_dependency "chef","~> 11.8.2"
  s.add_runtime_dependency "berkshelf","~> 2.0.12"

  s.add_development_dependency "rspec", "~> 2.0"

  s.homepage    =
    'https://github.com/RIYIC/lambom'
end
