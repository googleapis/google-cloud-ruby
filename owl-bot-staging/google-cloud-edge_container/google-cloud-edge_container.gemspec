# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/edge_container/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-edge_container"
  gem.version       = Google::Cloud::EdgeContainer::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "google-cloud-edge_container is the official client library for the Distributed Cloud Edge Container API."
  gem.summary       = "API Client library for the Distributed Cloud Edge Container API"
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 3.0"

  gem.add_dependency "google-cloud-core", "~> 1.6"
  gem.add_dependency "google-cloud-edge_container-v1", ">= 0.0", "< 2.a"
end
