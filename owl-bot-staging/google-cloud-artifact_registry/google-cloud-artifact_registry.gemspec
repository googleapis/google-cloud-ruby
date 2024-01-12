# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/artifact_registry/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-artifact_registry"
  gem.version       = Google::Cloud::ArtifactRegistry::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Artifact Registry stores and manages build artifacts in a scalable and integrated service built on Google infrastructure."
  gem.summary       = "API Client library for the Artifact Registry API"
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.6"

  gem.add_dependency "google-cloud-artifact_registry-v1", ">= 0.12", "< 2.a"
  gem.add_dependency "google-cloud-artifact_registry-v1beta2", ">= 0.11", "< 2.a"
  gem.add_dependency "google-cloud-core", "~> 1.6"

  gem.add_development_dependency "google-style", "~> 1.26.1"
  gem.add_development_dependency "minitest", "~> 5.16"
  gem.add_development_dependency "minitest-focus", "~> 1.1"
  gem.add_development_dependency "minitest-rg", "~> 5.2"
  gem.add_development_dependency "rake", ">= 13.0"
  gem.add_development_dependency "redcarpet", "~> 3.0"
  gem.add_development_dependency "simplecov", "~> 0.9"
  gem.add_development_dependency "yard", "~> 0.9"
end
