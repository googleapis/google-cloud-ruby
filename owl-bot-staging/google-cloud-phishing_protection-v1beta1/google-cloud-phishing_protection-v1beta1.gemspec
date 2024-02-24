# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/phishing_protection/v1beta1/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-phishing_protection-v1beta1"
  gem.version       = Google::Cloud::PhishingProtection::V1beta1::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Phishing Protection helps prevent users from accessing phishing sites by identifying various signals associated with malicious content, including the use of your brand assets, classifying malicious content that uses your brand and reporting the unsafe URLs to Google Safe Browsing. Note that google-cloud-phishing_protection-v1beta1 is a version-specific client library. For most uses, we recommend installing the main client library google-cloud-phishing_protection instead. See the readme for more details."
  gem.summary       = "API Client library for the Phishing Protection V1beta1 API"
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      `git ls-files -- proto_docs/*`.split("\n") +
                      ["README.md", "LICENSE.md", "AUTHENTICATION.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.7"

  gem.add_dependency "gapic-common", ">= 0.21.1", "< 2.a"
  gem.add_dependency "google-cloud-errors", "~> 1.0"
end
