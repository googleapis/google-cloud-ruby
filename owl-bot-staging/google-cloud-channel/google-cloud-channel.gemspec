# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/channel/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-channel"
  gem.version       = Google::Cloud::Channel::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "You can use Channel Services to manage your relationships with your partners and your customers. Channel Services include a console and APIs to view and provision links between distributors and resellers, customers and entitlements."
  gem.summary       = "API Client library for the Cloud Channel API"
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.7"

  gem.add_dependency "google-cloud-channel-v1", ">= 0.23", "< 2.a"
  gem.add_dependency "google-cloud-core", "~> 1.6"
end
