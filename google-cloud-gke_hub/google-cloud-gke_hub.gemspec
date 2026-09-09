# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/gke_hub/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-gke_hub"
  gem.version       = Google::Cloud::GkeHub::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "The GKE Hub service handles the registration of many Kubernetes clusters to Google Cloud, and the management of multi-cluster features over those clusters."
  gem.summary       = "The GKE Hub service handles the registration of many Kubernetes clusters to Google Cloud, and the management of multi-cluster features over those clusters."
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 3.2"

  gem.add_dependency "google-cloud-core", "~> 1.6"
  gem.add_dependency "google-cloud-gke_hub-v1", "~> 2.0"
end
