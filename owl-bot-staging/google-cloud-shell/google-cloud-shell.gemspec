# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/shell/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-shell"
  gem.version       = Google::Cloud::Shell::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Cloud Shell is an interactive shell environment for Google Cloud that makes it easy for you to learn and experiment with Google Cloud and manage your projects and resources from your web browser."
  gem.summary       = "API Client library for the Cloud Shell API"
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.7"

  gem.add_dependency "google-cloud-core", "~> 1.6"
  gem.add_dependency "google-cloud-shell-v1", ">= 0.7", "< 2.a"
end
