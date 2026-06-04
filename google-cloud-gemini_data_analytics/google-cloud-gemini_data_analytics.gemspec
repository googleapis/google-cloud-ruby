# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/gemini_data_analytics/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-gemini_data_analytics"
  gem.version       = Google::Cloud::GeminiDataAnalytics::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "The Gemini Data Analytics API enables developers to build intelligent data analytics applications. Leverage AI-powered chat interfaces to allow users to interact with and analyze structured data using natural language."
  gem.summary       = "The Gemini Data Analytics API enables developers to build intelligent data analytics applications. Leverage AI-powered chat interfaces to allow users to interact with and analyze structured data using natural language."
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 3.2"

  gem.add_dependency "google-cloud-core", "~> 1.6"
  gem.add_dependency "google-cloud-gemini_data_analytics-v1beta", ">= 0.0", "< 2.a"
end
