# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'services/version'

Gem::Specification.new do |spec|
  spec.name          = "jn_services"
  spec.version       = Services::VERSION
  spec.authors       = ["Jesse Nelson"]
  spec.email         = ["spheromak@gmail.com"]
  spec.description   = %q{Consitently model servives with etcd in and outside chef}
  spec.summary       = spec.description
  spec.homepage      = "https://github.com/spheromak/services"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "etcd", "~> 0.2.0.alpha"
  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  # aparently macaddr has broken gem dep on systemu
  spec.add_development_dependency "systemu"
  spec.add_development_dependency "uuid"
  spec.add_development_dependency "rubocop"
  spec.add_development_dependency 'simplecov'
end
