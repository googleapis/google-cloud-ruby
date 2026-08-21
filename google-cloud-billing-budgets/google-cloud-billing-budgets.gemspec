# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/billing/budgets/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-billing-budgets"
  gem.version       = Google::Cloud::Billing::Budgets::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "The Cloud Billing Budget API stores Cloud Billing budgets, which define a budget plan and the rules to execute as spend is tracked against that plan."
  gem.summary       = "The Cloud Billing Budget API stores Cloud Billing budgets, which define a budget plan and the rules to execute as spend is tracked against that plan."
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 3.2"

  gem.add_dependency "google-cloud-billing-budgets-v1", "~> 1.2"
  gem.add_dependency "google-cloud-core", "~> 1.6"
end
