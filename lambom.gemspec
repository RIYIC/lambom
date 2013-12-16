Gem::Specification.new do |s|
  s.name        = 'lambom'
  s.version     = '0.1.0'
  s.date        = '2013-12-13'
  s.summary     = "Tool to apply riyic servers personalities"
  s.description = "Riyic is a server configuration service based on chef (http://riyic.com). The lambom gem is a tool to apply, through chef-solo, your riyic configurations"
  s.authors     = ["J. Gomez"]
  s.email       = 'alambike@gmail.com'
  s.require_paths = ["lib"]
  s.executables << 'lambom'
  s.files         = `git ls-files`.split($/)
  s.license       = 'Apache-2.0'

  s.add_runtime_dependency "oj","~> 2.0"
  s.add_runtime_dependency "mixlib-authentication","~> 1.3"
  s.add_runtime_dependency "mixlib-shellout","~> 1.3"
  
  s.homepage    =
    'https://github.com/RIYIC/lambom'
end
