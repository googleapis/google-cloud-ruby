# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/functions/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-functions"
  gem.version       = Google::Cloud::Functions::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "The Cloud Functions API manages lightweight user-provided functions executed in response to events."
  gem.summary       = "API Client library for the Cloud Functions API"
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.7"

  gem.add_dependency "google-cloud-core", "~> 1.6"
  gem.add_dependency "google-cloud-functions-v1", ">= 0.13", "< 2.a"
end
