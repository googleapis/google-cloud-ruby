# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/deploy/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-deploy"
  gem.version       = Google::Cloud::Deploy::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Google Cloud Deploy is a managed service that automates delivery of your applications to a series of target environments in a defined promotion sequence."
  gem.summary       = "API Client library for the Google Cloud Deploy API"
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.7"

  gem.add_dependency "google-cloud-core", "~> 1.6"
  gem.add_dependency "google-cloud-deploy-v1", ">= 0.17", "< 2.a"
end
