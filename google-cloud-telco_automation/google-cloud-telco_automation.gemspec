# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/telco_automation/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-telco_automation"
  gem.version       = Google::Cloud::TelcoAutomation::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "APIs to automate management of cloud infrastructure for network functions."
  gem.summary       = "APIs to automate management of cloud infrastructure for network functions."
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.7"

  gem.add_dependency "google-cloud-core", "~> 1.6"
  gem.add_dependency "google-cloud-telco_automation-v1", ">= 0.2", "< 2.a"
end
