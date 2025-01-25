# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/analytics/data/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-analytics-data"
  gem.version       = Google::Analytics::Data::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "The Google Analytics Data API provides programmatic methods to access report data in Google Analytics 4 (GA4) properties. Google Analytics 4 helps you understand how people use your web, iOS, or Android app."
  gem.summary       = "API Client library for the Google Analytics Data API"
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.7"

  gem.add_dependency "google-analytics-data-v1beta", ">= 0.11", "< 2.a"
  gem.add_dependency "google-cloud-core", "~> 1.6"
end
