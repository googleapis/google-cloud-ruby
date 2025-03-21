# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/gke_hub/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-gke_hub"
  gem.version       = Google::Cloud::GkeHub::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "The GKE Hub API centrally manages features and services on all your Kubernetes clusters running in a variety of environments, including Google cloud, on premises in customer datacenters, or other third party clouds."
  gem.summary       = "API Client library for the GKE Hub API"
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 3.0"

  gem.add_dependency "google-cloud-core", "~> 1.6"
  gem.add_dependency "google-cloud-gke_hub-v1", "~> 2.0"
end
