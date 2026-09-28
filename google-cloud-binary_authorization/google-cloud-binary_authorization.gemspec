# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/binary_authorization/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-binary_authorization"
  gem.version       = Google::Cloud::BinaryAuthorization::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "The management interface for Binary Authorization, a service that provides policy-based deployment validation and control for images deployed to Google Kubernetes Engine (GKE), Anthos Service Mesh, Anthos Clusters, and Cloud Run."
  gem.summary       = "The management interface for Binary Authorization, a service that provides policy-based deployment validation and control for images deployed to Google Kubernetes Engine (GKE), Anthos Service Mesh, Anthos Clusters, and Cloud Run."
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 3.2"

  gem.add_dependency "google-cloud-binary_authorization-v1", "~> 1.2"
  gem.add_dependency "google-cloud-core", "~> 1.6"
end
