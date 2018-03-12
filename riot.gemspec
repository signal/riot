# -*- encoding: utf-8 -*-
$:.unshift(File.expand_path("../lib", __FILE__))
require "riot/version"

Gem::Specification.new do |s|
  s.name          = %q{signal-riot}
  s.version       = Riot::VERSION
  s.platform      = Gem::Platform::RUBY
  s.authors       = ["Justin 'Gus' Knowlden"]
  s.summary       = %q{An extremely fast, expressive, and context-driven unit-testing framework. Protest the slow test.}
  s.description   = %q{An extremely fast, expressive, and context-driven unit-testing framework. A replacement for all other testing frameworks. Protest the slow test.}
  s.email         = %q{gus@gusg.us}
  s.files         = `git ls-files`.split("\n") 
  s.homepage      = %q{http://github.com/thumblemonks/riot}
  s.require_paths = ["lib"]
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")

  s.add_dependency 'rr', '>=0'
end


