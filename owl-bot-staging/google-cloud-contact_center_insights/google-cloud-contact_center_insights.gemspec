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

  gem.required_ruby_version = ">= 2.7"

  gem.add_dependency "google-cloud-contact_center_insights-v1", ">= 0.20", "< 2.a"
  gem.add_dependency "google-cloud-core", "~> 1.6"
end
