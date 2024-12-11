# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/billing/budgets/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-billing-budgets"
  gem.version       = Google::Cloud::Billing::Budgets::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Provides methods to view, create, and manage Cloud Billing budgets programmatically at scale."
  gem.summary       = "API Client library for the Billing Budgets API"
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.7"

  gem.add_dependency "google-cloud-billing-budgets-v1", ">= 0.7", "< 2.a"
  gem.add_dependency "google-cloud-billing-budgets-v1beta1", ">= 0.11", "< 2.a"
  gem.add_dependency "google-cloud-core", "~> 1.6"
end
