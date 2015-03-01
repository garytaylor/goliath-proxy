# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'goliath/proxy/version'

Gem::Specification.new do |spec|
  spec.name          = "goliath-proxy"
  spec.version       = Goliath::Proxy::VERSION
  spec.authors       = ["Gary Taylor"]
  spec.email         = ["gary.taylor@hismessages.com"]
  spec.summary       = %q{Use goliath as a framework for a programmable proxy server}
  spec.description   = %q{Goliath is a fabulous framework for writing rack based web applications.  With this gem, you can also use it to write web proxies in rack style.}
  spec.homepage      = "https://github.com/garytaylor/goliath-proxy"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
end
