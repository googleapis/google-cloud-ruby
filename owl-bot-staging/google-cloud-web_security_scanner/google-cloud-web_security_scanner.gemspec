# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/web_security_scanner/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-web_security_scanner"
  gem.version       = Google::Cloud::WebSecurityScanner::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Web Security Scanner scans your Compute and App Engine apps for common web vulnerabilities."
  gem.summary       = "API Client library for the Web Security Scanner API"
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.7"

  gem.add_dependency "google-cloud-core", "~> 1.6"
  gem.add_dependency "google-cloud-web_security_scanner-v1", ">= 0.9", "< 2.a"
  gem.add_dependency "google-cloud-web_security_scanner-v1beta", ">= 0.8", "< 2.a"
end
