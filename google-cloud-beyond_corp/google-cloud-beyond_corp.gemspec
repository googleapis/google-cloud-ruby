# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/beyond_corp/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-beyond_corp"
  gem.version       = Google::Cloud::BeyondCorp::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Chrome Enterprise Premium is a secure enterprise browsing solution that provides secure access to applications and resources, and offers integrated threat and data protection. It adds an extra layer of security to safeguard your Chrome browser environment, including Data Loss Prevention (DLP), real-time URL and file scanning, and Context-Aware Access for SaaS and web apps."
  gem.summary       = "API client library for the BeyondCorp API"
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 3.2"

  gem.add_dependency "google-cloud-beyond_corp-app_connections-v1", ">= 0.4", "< 2.a"
  gem.add_dependency "google-cloud-core", "~> 1.6"
  gem.add_dependency "google-cloud-beyond_corp-app_connectors-v1", ">= 0.4", "< 2.a"
  gem.add_dependency "google-cloud-beyond_corp-app_gateways-v1", ">= 0.4", "< 2.a"
  gem.add_dependency "google-cloud-beyond_corp-client_gateways-v1", ">= 0.4", "< 2.a"
end
