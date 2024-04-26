# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/binary_authorization/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-binary_authorization"
  gem.version       = Google::Cloud::BinaryAuthorization::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Binary Authorization is a service on Google Cloud that provides centralized software supply-chain security for applications that run on Google Kubernetes Engine (GKE) and GKE on-prem."
  gem.summary       = "API Client library for the Binary Authorization API"
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.7"

  gem.add_dependency "google-cloud-binary_authorization-v1", ">= 0.6", "< 2.a"
  gem.add_dependency "google-cloud-binary_authorization-v1beta1", ">= 0.12", "< 2.a"
  gem.add_dependency "google-cloud-core", "~> 1.6"
end
