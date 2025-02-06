# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/app_hub/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-app_hub"
  gem.version       = Google::Cloud::AppHub::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "google-cloud-app_hub is the official client library for the App Hub API."
  gem.summary       = "API Client library for the App Hub API"
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 3.0"

  gem.add_dependency "google-cloud-app_hub-v1", ">= 0.0", "< 2.a"
  gem.add_dependency "google-cloud-core", "~> 1.6"
end
