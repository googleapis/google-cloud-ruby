# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/apigee_registry/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-apigee_registry"
  gem.version       = Google::Cloud::ApigeeRegistry::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "The Apigee Registry API allows teams to upload and share machine-readable descriptions of APIs that are in use and in development. These descriptions include API specifications in standard formats like OpenAPI, the Google API Discovery Service Format, and the Protocol Buffers Language. These API specifications can be used by tools like linters, browsers, documentation generators, test runners, proxies, and API client and server generators. The Registry API itself can be seen as a machine-readable enterprise API catalog designed to back online directories, portals, and workflow managers."
  gem.summary       = "API Client library for the Apigee Registry API"
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.7"

  gem.add_dependency "google-cloud-apigee_registry-v1", ">= 0.7", "< 2.a"
  gem.add_dependency "google-cloud-core", "~> 1.6"
end
