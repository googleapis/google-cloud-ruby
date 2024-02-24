# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/support/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-support"
  gem.version       = Google::Cloud::Support::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Manages Google Cloud technical support cases for Customer Care support offerings."
  gem.summary       = "Manages Google Cloud technical support cases for Customer Care support offerings."
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.7"

  gem.add_dependency "google-cloud-core", "~> 1.6"
  gem.add_dependency "google-cloud-support-v2", ">= 0.3", "< 2.a"
end
