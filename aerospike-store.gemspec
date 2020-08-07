# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'aerospike/store/version'

Gem::Specification.new do |spec|
  spec.name          = "aerospike-store"
  spec.version       = Aerospike::Store::VERSION
  spec.authors       = ["Amir Rahimi Farahani"]
  spec.email         = ["amirrf@gmail.com"]
  spec.summary       = "Aerospike Session and Cache stores for Ruby on Rails"
  spec.description   = "A session store and a cache store backed by Aerospike for Rails."
  spec.homepage      = "https://github.com/amirrf/aerospike-store-rails"
  spec.license       = "Apache2.0"
  spec.files         = Dir.glob("lib/**/*") + %w(LICENSE.txt README.md)
  spec.require_paths = ["lib"]
  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_runtime_dependency "aerospike", '~> 0.1', '>= 0.1.3'
  spec.add_runtime_dependency "activesupport", "~> 4"
  spec.add_runtime_dependency "actionpack", "~> 4"
end