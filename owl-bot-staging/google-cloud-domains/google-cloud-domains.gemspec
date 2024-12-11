# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/domains/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-domains"
  gem.version       = Google::Cloud::Domains::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "The Cloud Domains API provides registration, management and configuration of domain names."
  gem.summary       = "API Client library for the Cloud Domains API"
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.7"

  gem.add_dependency "google-cloud-core", "~> 1.6"
  gem.add_dependency "google-cloud-domains-v1", ">= 0.6", "< 2.a"
  gem.add_dependency "google-cloud-domains-v1beta1", ">= 0.8", "< 2.a"
end
