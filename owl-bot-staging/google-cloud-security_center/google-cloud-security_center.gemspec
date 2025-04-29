# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/security_center/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-security_center"
  gem.version       = Google::Cloud::SecurityCenter::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Security Command Center API provides access to temporal views of assets and findings within an organization."
  gem.summary       = "API Client library for the Security Command Center API"
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 3.0"

  gem.add_dependency "google-cloud-core", "~> 1.6"
  gem.add_dependency "google-cloud-security_center-v1", "~> 1.0"
  gem.add_dependency "google-cloud-security_center-v2", "~> 1.0"
end
