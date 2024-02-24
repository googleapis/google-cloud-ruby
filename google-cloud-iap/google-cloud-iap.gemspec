# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/iap/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-iap"
  gem.version       = Google::Cloud::Iap::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "IAP lets you establish a central authorization layer for applications accessed by HTTPS, so you can use an application-level access control model instead of relying on network-level firewalls."
  gem.summary       = "API Client library for the Identity-Aware Proxy API"
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.7"

  gem.add_dependency "google-cloud-core", "~> 1.6"
  gem.add_dependency "google-cloud-iap-v1", ">= 0.11", "< 2.a"
end
