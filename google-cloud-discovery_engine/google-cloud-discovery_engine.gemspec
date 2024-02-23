# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/discovery_engine/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-discovery_engine"
  gem.version       = Google::Cloud::DiscoveryEngine::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Discovery Engine API."
  gem.summary       = "Discovery Engine API."
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.7"

  gem.add_dependency "google-cloud-core", "~> 1.6"
  gem.add_dependency "google-cloud-discovery_engine-v1", ">= 0.4", "< 2.a"
  gem.add_dependency "google-cloud-discovery_engine-v1beta", ">= 0.7", "< 2.a"
end
