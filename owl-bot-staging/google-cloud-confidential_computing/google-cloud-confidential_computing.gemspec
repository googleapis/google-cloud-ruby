# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/confidential_computing/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-confidential_computing"
  gem.version       = Google::Cloud::ConfidentialComputing::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Attestation verifier for Confidential Space."
  gem.summary       = "Attestation verifier for Confidential Space."
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.7"

  gem.add_dependency "google-cloud-confidential_computing-v1", ">= 0.7", "< 2.a"
  gem.add_dependency "google-cloud-core", "~> 1.6"
end
