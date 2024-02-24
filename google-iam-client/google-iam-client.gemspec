# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/iam/client/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-iam-client"
  gem.version       = Google::Iam::Client::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Manages identity and access control policies for Google Cloud Platform resources."
  gem.summary       = "API Client library for the IAM API"
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.7"

  gem.add_dependency "google-cloud-core", "~> 1.6"
  gem.add_dependency "google-iam-v2", ">= 0.5", "< 2.a"
end
