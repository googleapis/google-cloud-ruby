# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/iam/credentials/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-iam-credentials"
  gem.version       = Google::Iam::Credentials::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "The Service Account Credentials API creates short-lived credentials for Identity and Access Management (IAM) service accounts. You can also use this API to sign JSON Web Tokens (JWTs), as well as blobs of binary data that contain other types of tokens."
  gem.summary       = "API Client library for the IAM Service Account Credentials API"
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.6"

  gem.add_dependency "google-cloud-core", "~> 1.6"
  gem.add_dependency "google-iam-credentials-v1", ">= 0.3", "< 2.a"

  gem.add_development_dependency "google-style", "~> 1.26.1"
  gem.add_development_dependency "minitest", "~> 5.16"
  gem.add_development_dependency "minitest-focus", "~> 1.1"
  gem.add_development_dependency "minitest-rg", "~> 5.2"
  gem.add_development_dependency "rake", ">= 13.0"
  gem.add_development_dependency "redcarpet", "~> 3.0"
  gem.add_development_dependency "simplecov", "~> 0.9"
  gem.add_development_dependency "yard", "~> 0.9"
end
