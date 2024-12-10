# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/access_approval/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-access_approval"
  gem.version       = Google::Cloud::AccessApproval::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "An API for controlling access to data by Google personnel."
  gem.summary       = "API Client library for the Access Approval API"
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.7"

  gem.add_dependency "google-cloud-access_approval-v1", ">= 0.11", "< 2.a"
  gem.add_dependency "google-cloud-core", "~> 1.6"
end
