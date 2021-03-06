# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'memtf/version'

Gem::Specification.new do |spec|
  spec.name          = "memtf"
  spec.version       = Memtf::VERSION
  spec.authors       = ["Matthew Dressel"]
  spec.email         = ["matt.dressel@gmail.com"]
  spec.description   = %q{A simple utility to help you isolate the little bastards that are stealing your memory and your sanity.}
  spec.summary       = %q{Leaking memory like a sieve? Cursing? Memtf is here to help.}
  spec.homepage      = "http://github.com/dresselm/memtf"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'multi_json'
  spec.add_dependency 'terminal-table'

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "fakefs"
  spec.add_development_dependency "guard-rspec"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "yard"
end
