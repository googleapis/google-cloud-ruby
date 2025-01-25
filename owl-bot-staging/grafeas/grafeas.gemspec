# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/grafeas/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "grafeas"
  gem.version       = Grafeas::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "The Grafeas API stores, and enables querying and retrieval of, critical metadata about all of your software artifacts."
  gem.summary       = "API Client library for the Grafeas API"
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "LICENSE.md", ".yardopts", "MIGRATING.md"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.7"

  gem.add_dependency "google-cloud-core", "~> 1.6"
  gem.add_dependency "grafeas-v1", ">= 0.14", "< 2.a"
end
