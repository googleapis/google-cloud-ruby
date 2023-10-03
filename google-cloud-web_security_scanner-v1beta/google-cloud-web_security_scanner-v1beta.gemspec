# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/web_security_scanner/v1beta/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-web_security_scanner-v1beta"
  gem.version       = Google::Cloud::WebSecurityScanner::V1beta::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Web Security Scanner scans your Compute and App Engine apps for common web vulnerabilities. Note that google-cloud-web_security_scanner-v1beta is a version-specific client library. For most uses, we recommend installing the main client library google-cloud-web_security_scanner instead. See the readme for more details."
  gem.summary       = "Scans your Compute and App Engine apps for common web vulnerabilities."
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      `git ls-files -- proto_docs/*`.split("\n") +
                      ["README.md", "LICENSE.md", "AUTHENTICATION.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.6"

  gem.add_dependency "gapic-common", ">= 0.20.0", "< 2.a"
  gem.add_dependency "google-cloud-errors", "~> 1.0"

  gem.add_development_dependency "google-style", "~> 1.26.3"
  gem.add_development_dependency "minitest", "~> 5.16"
  gem.add_development_dependency "minitest-focus", "~> 1.1"
  gem.add_development_dependency "minitest-rg", "~> 5.2"
  gem.add_development_dependency "rake", ">= 13.0"
  gem.add_development_dependency "redcarpet", "~> 3.0"
  gem.add_development_dependency "simplecov", "~> 0.18"
  gem.add_development_dependency "yard", "~> 0.9"
end
