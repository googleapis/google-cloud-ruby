# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/identity/access_context_manager/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-identity-access_context_manager"
  gem.version       = Google::Identity::AccessContextManager::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "An API for setting attribute based access control to requests to GCP services."
  gem.summary       = "An API for setting attribute based access control to requests to GCP services."
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 3.2"

  gem.add_dependency "google-cloud-core", "~> 1.6"
  gem.add_dependency "google-identity-access_context_manager-v1", ">= 0.7", "< 2.a"
end
