# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/phishing_protection/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-phishing_protection"
  gem.version       = Google::Cloud::PhishingProtection::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Phishing Protection helps prevent users from accessing phishing sites by identifying various signals associated with malicious content, including the use of your brand assets, classifying malicious content that uses your brand and reporting the unsafe URLs to Google Safe Browsing. Once a site is propagated to Safe Browsing, users will see warnings across more than 4 billion devices."
  gem.summary       = "Phishing Protection helps prevent users from accessing phishing sites by identifying various signals associated with malicious content, including the use of your brand assets, classifying malicious content that uses your brand and reporting the unsafe URLs to Google Safe Browsing. Once a site is propagated to Safe Browsing, users will see warnings across more than 4 billion devices."
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts", "MIGRATING.md"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 3.2"

  gem.add_dependency "google-cloud-core", "~> 1.6"
  gem.add_dependency "google-cloud-phishing_protection-v1beta1", ">= 0.8", "< 2.a"
end
