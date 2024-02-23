# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/build/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-build"
  gem.version       = Google::Cloud::Build::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Cloud Build is a service that executes your builds on Google Cloud Platform infrastructure. Cloud Build can import source code from Google Cloud Storage, Cloud Source Repositories, GitHub, or Bitbucket, execute a build to your specifications, and produce artifacts such as Docker containers or Java archives."
  gem.summary       = "API Client library for the Cloud Build API"
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.7"

  gem.add_dependency "google-cloud-build-v1", ">= 0.26", "< 2.a"
  gem.add_dependency "google-cloud-core", "~> 1.6"
end
