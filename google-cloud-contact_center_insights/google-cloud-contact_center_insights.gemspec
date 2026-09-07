# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/contact_center_insights/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-contact_center_insights"
  gem.version       = Google::Cloud::ContactCenterInsights::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Contact Center Insights provides out-of-the-box and custom modeling techniques to make it easier for contact center teams to better understand customer interaction data."
  gem.summary       = "Contact Center Insights provides out-of-the-box and custom modeling techniques to make it easier for contact center teams to better understand customer interaction data."
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 3.2"

  gem.add_dependency "google-cloud-contact_center_insights-v1", ">= 0.20", "< 2.a"
  gem.add_dependency "google-cloud-core", "~> 1.6"
end
