# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "lambom/version"

Gem::Specification.new do |s|
  s.name        = 'lambom'
  s.version     = Lambom::VERSION
  s.date        = '2013-12-23'
  s.summary     = "Tool to apply chef configurations"
  s.description = <<-EOF
Riyic is a server configuration service based on chef (http://riyic.com).
The lambom gem is a tool to apply defined chef configurations stored in riyic service, 
or in a pair of plain text files (the json attributes file and berkshelf file).
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
