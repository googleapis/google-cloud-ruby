# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/edge_container/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-edge_container"
  gem.version       = Google::Cloud::EdgeContainer::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Google Distributed Cloud Edge is a fully managed product that brings Google Cloud infrastructure and services closer to where data is being generated and consumed."
  gem.summary       = "Google Distributed Cloud Edge is a fully managed product that brings Google Cloud infrastructure and services closer to where data is being generated and consumed."
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 3.2"

  gem.add_dependency "google-cloud-core", "~> 1.6"
  gem.add_dependency "google-cloud-edge_container-v1", "~> 1.0"
end
