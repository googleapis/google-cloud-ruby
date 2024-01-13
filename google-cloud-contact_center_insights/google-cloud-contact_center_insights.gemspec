# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/contact_center_insights/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-contact_center_insights"
  gem.version       = Google::Cloud::ContactCenterInsights::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Contact Center AI Insights helps users detect and visualize patterns in their contact center data. Understanding conversational data drives business value, improves operational efficiency, and provides a voice for customer feedback."
  gem.summary       = "API Client library for the Contact Center AI Insights API"
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.6"

  gem.add_dependency "google-cloud-contact_center_insights-v1", ">= 0.20", "< 2.a"
  gem.add_dependency "google-cloud-core", "~> 1.6"

  gem.add_development_dependency "google-style", "~> 1.26.1"
  gem.add_development_dependency "minitest", "~> 5.16"
  gem.add_development_dependency "minitest-focus", "~> 1.1"
  gem.add_development_dependency "minitest-rg", "~> 5.2"
  gem.add_development_dependency "rake", ">= 13.0"
  gem.add_development_dependency "redcarpet", "~> 3.0"
  gem.add_development_dependency "simplecov", "~> 0.9"
  gem.add_development_dependency "yard", "~> 0.9"
end
